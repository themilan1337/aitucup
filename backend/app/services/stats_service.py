from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from datetime import date, timedelta, datetime
from typing import Dict, Any, List
from app.models.workout import WorkoutSession, ExercisePerformance
from app.models.user import User
import logging

logger = logging.getLogger(__name__)

class StatsService:
    """Service for calculating user statistics and progress"""

    @staticmethod
    async def get_user_dashboard_stats(db: AsyncSession, user_id: str) -> Dict[str, Any]:
        """Get summary stats for the user dashboard"""
        
        # Total workouts
        workouts_query = select(func.count(WorkoutSession.id)).filter(WorkoutSession.user_id == user_id)
        total_workouts = (await db.execute(workouts_query)).scalar() or 0
        
        # Total reps
        reps_query = select(func.sum(ExercisePerformance.reps)).join(WorkoutSession).filter(WorkoutSession.user_id == user_id)
        total_reps = (await db.execute(reps_query)).scalar() or 0
        
        # Total calories
        calories_query = select(func.sum(WorkoutSession.total_calories)).filter(WorkoutSession.user_id == user_id)
        total_calories = (await db.execute(calories_query)).scalar() or 0
        
        # Average form accuracy
        accuracy_query = select(func.avg(WorkoutSession.average_form_accuracy)).filter(WorkoutSession.user_id == user_id)
        avg_accuracy = (await db.execute(accuracy_query)).scalar() or 0.0
        
        # Current streak
        streak = await StatsService._calculate_streak(db, user_id)
        
        return {
            "total_workouts": total_workouts,
            "total_reps": total_reps,
            "total_calories": round(total_calories, 1),
            "average_accuracy": round(avg_accuracy, 2),
            "current_streak": streak,
            "streak_text": f"{streak} дней подряд!" if streak > 0 else "Начни свою серию!"
        }

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

stats_service = StatsService()
