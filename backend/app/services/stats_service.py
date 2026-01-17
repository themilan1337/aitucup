from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, and_, case, extract
from datetime import date, timedelta, datetime
from typing import Dict, Any, List, Optional
from app.models.workout import WorkoutSession, ExercisePerformance
from app.models.user import User
import logging

logger = logging.getLogger(__name__)

class StatsService:
    """Service for calculating user statistics and progress"""

    @staticmethod
    async def get_user_dashboard_stats(
        db: AsyncSession,
        user_id: str,
        period: str = "all"
    ) -> Dict[str, Any]:
        """Get summary stats for the user dashboard

        Args:
            db: Database session
            user_id: User UUID
            period: Time period filter - 'week', 'month', or 'all' (default)
        """
        # Calculate date filter
        date_filter = StatsService._get_date_filter(period)
        base_filter = WorkoutSession.user_id == user_id
        if date_filter:
            base_filter = and_(base_filter, WorkoutSession.completed_at >= date_filter)

        # Total workouts
        workouts_query = select(func.count(WorkoutSession.id)).filter(base_filter)
        total_workouts = (await db.execute(workouts_query)).scalar() or 0

        # Total reps
        reps_query = (
            select(func.sum(ExercisePerformance.reps))
            .join(WorkoutSession)
            .filter(base_filter)
        )
        total_reps = (await db.execute(reps_query)).scalar() or 0

        # Total calories
        calories_query = select(func.sum(WorkoutSession.total_calories)).filter(base_filter)
        total_calories = (await db.execute(calories_query)).scalar() or 0

        # Total duration in minutes
        duration_query = select(func.sum(WorkoutSession.total_duration)).filter(base_filter)
        total_seconds = (await db.execute(duration_query)).scalar() or 0
        total_minutes = round(total_seconds / 60, 0)

        # Average form accuracy
        accuracy_query = select(func.avg(WorkoutSession.average_form_accuracy)).filter(base_filter)
        avg_accuracy = (await db.execute(accuracy_query)).scalar() or 0.0

        # Current streak (always calculated for all time)
        streak = await StatsService._calculate_streak(db, user_id)

        return {
            "total_workouts": total_workouts,
            "total_reps": total_reps,
            "total_minutes": int(total_minutes),
            "total_calories": round(total_calories, 1),
            "average_accuracy": round(avg_accuracy, 2),
            "current_streak": streak,
            "streak_text": f"{streak} дней подряд!" if streak > 0 else "Начни свою серию!"
        }

    @staticmethod
    def _get_date_filter(period: str) -> Optional[datetime]:
        """Get datetime filter based on period"""
        now = datetime.utcnow()
        if period == "week":
            return now - timedelta(days=7)
        elif period == "month":
            return now - timedelta(days=30)
        else:  # "all"
            return None

    @staticmethod
    async def _calculate_streak(db: AsyncSession, user_id: str) -> int:
        """Calculate current daily workout streak"""
        result = await db.execute(
            select(func.date(WorkoutSession.completed_at))
            .filter(WorkoutSession.user_id == user_id)
            .distinct()
            .order_by(desc(func.date(WorkoutSession.completed_at)))
        )
        dates = [r[0] for r in result.all()]
        
        if not dates:
            return 0
            
        today = date.today()
        yesterday = today - timedelta(days=1)
        
        # Check if they worked out today or yesterday (to maintain streak)
        if dates[0] not in [today, yesterday]:
            return 0
            
        streak = 1
        for i in range(len(dates) - 1):
            if dates[i] - timedelta(days=1) == dates[i+1]:
                streak += 1
            else:
                break
        return streak

    @staticmethod
    async def get_accuracy_trend(db: AsyncSession, user_id: str, days: int = 7) -> List[Dict[str, Any]]:
        """Get form accuracy trend for the last N days"""
        since_date = datetime.utcnow() - timedelta(days=days)
        result = await db.execute(
            select(
                func.date(WorkoutSession.completed_at).label("date"),
                func.avg(WorkoutSession.average_form_accuracy).label("avg_accuracy")
            )
            .filter(WorkoutSession.user_id == user_id, WorkoutSession.completed_at >= since_date)
            .group_by(func.date(WorkoutSession.completed_at))
            .order_by(func.date(WorkoutSession.completed_at))
        )

        return [{"date": str(r.date), "accuracy": round(r.avg_accuracy, 2)} for r in result.all()]

    @staticmethod
    async def get_personal_records(db: AsyncSession, user_id: str) -> Dict[str, Any]:
        """Get personal records (max reps/duration) for each exercise type"""

        # Get max reps for rep-based exercises
        rep_exercises = ["squat", "lunge", "pushup", "situp", "crunch",
                        "bicep_curl", "lateral_raise", "overhead_press",
                        "leg_raise", "knee_raise", "knee_press"]

        records = {}

        for exercise in rep_exercises:
            result = await db.execute(
                select(func.max(ExercisePerformance.reps))
                .join(WorkoutSession)
                .filter(
                    WorkoutSession.user_id == user_id,
                    ExercisePerformance.exercise_type == exercise
                )
            )
            max_reps = result.scalar() or 0
            records[exercise] = max_reps

        # Get max duration for plank (time-based exercise)
        result = await db.execute(
            select(func.max(ExercisePerformance.duration))
            .join(WorkoutSession)
            .filter(
                WorkoutSession.user_id == user_id,
                ExercisePerformance.exercise_type == "plank"
            )
        )
        records["plank"] = result.scalar() or 0

        return records

    @staticmethod
    async def get_weekly_frequency(db: AsyncSession, user_id: str) -> List[bool]:
        """Get workout frequency for the current week (Mon-Sun)

        Returns:
            List of 7 booleans representing whether user worked out on each day
            [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
        """
        # Get start of current week (Monday)
        today = date.today()
        start_of_week = today - timedelta(days=today.weekday())
        end_of_week = start_of_week + timedelta(days=6)

        # Get all workout dates in current week
        result = await db.execute(
            select(func.date(WorkoutSession.completed_at))
            .filter(
                WorkoutSession.user_id == user_id,
                func.date(WorkoutSession.completed_at) >= start_of_week,
                func.date(WorkoutSession.completed_at) <= end_of_week
            )
            .distinct()
        )

        workout_dates = {r[0] for r in result.all()}

        # Create array for each day of the week
        frequency = []
        for i in range(7):
            day = start_of_week + timedelta(days=i)
            frequency.append(day in workout_dates)

        return frequency

stats_service = StatsService()
