from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from typing import List
from app.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.workout import WorkoutSession, ExercisePerformance
from app.models.plan import PlanDay
from app.schemas.workout import WorkoutSessionCreate, WorkoutSessionResponse
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/", response_model=WorkoutSessionResponse, status_code=status.HTTP_201_CREATED)
async def log_workout_session(
    workout_data: WorkoutSessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Log a completed workout session with exercise details"""
    
    # Create session
    new_session = WorkoutSession(
        user_id=current_user.id,
        plan_day_id=workout_data.plan_day_id,
        started_at=workout_data.started_at,
        completed_at=workout_data.completed_at,
        total_duration=workout_data.total_duration,
        total_calories=workout_data.total_calories,
        average_form_accuracy=workout_data.average_form_accuracy
    )
    db.add(new_session)
    await db.flush() # Get session.id
    
    # Create exercise performances
    for ex in workout_data.exercises:
        perf = ExercisePerformance(
            workout_session_id=new_session.id,
            exercise_type=ex.exercise_type,
            reps=ex.reps,
            duration=ex.duration,
            form_accuracy=ex.form_accuracy,
            form_corrections=ex.form_corrections,
            calories_burned=ex.calories_burned,
            order_index=ex.order_index
        )
        db.add(perf)
    
    # Mark plan day as completed if provided
    if workout_data.plan_day_id:
        result = await db.execute(
            select(PlanDay).filter(PlanDay.id == workout_data.plan_day_id)
        )
        plan_day = result.scalars().first()
        if plan_day:
            plan_day.is_completed = True
            plan_day.completed_at = workout_data.completed_at
            
    await db.commit()
    await db.refresh(new_session)
    
    # Explicitly load exercises for the response
    result = await db.execute(
        select(ExercisePerformance)
        .filter(ExercisePerformance.workout_session_id == new_session.id)
        .order_by(ExercisePerformance.order_index)
    )
    new_session.exercises = result.scalars().all()
    
    return new_session

@router.get("/history", response_model=List[WorkoutSessionResponse])
async def get_workout_history(
    limit: int = 10,
    offset: int = 0,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get workout history for the current user"""
    result = await db.execute(
        select(WorkoutSession)
        .filter(WorkoutSession.user_id == current_user.id)
        .order_by(desc(WorkoutSession.completed_at))
        .limit(limit)
        .offset(offset)
    )
    sessions = result.scalars().all()
    return sessions

@router.get("/{session_id}", response_model=WorkoutSessionResponse)
async def get_workout_session(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get details of a specific workout session"""
    result = await db.execute(
        select(WorkoutSession)
        .filter(WorkoutSession.id == session_id, WorkoutSession.user_id == current_user.id)
    )
    session = result.scalars().first()
    
    if not session:
        raise HTTPException(status_code=404, detail="Workout session not found")
        
    return session
