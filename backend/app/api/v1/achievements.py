from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.achievement import Achievement, UserAchievement
from app.schemas.achievement import AchievementResponse, UserAchievementResponse

router = APIRouter()

@router.get("/", response_model=List[AchievementResponse])
async def get_all_achievements(
    db: AsyncSession = Depends(get_db)
):
    """Get list of all possible achievements"""
    result = await db.execute(select(Achievement))
    return result.scalars().all()

@router.get("/my", response_model=List[UserAchievementResponse])
async def get_my_achievements(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get achievements unlocked by the current user"""
    result = await db.execute(
        select(UserAchievement)
        .filter(UserAchievement.user_id == current_user.id)
        .order_by(UserAchievement.unlocked_at.desc())
    )
    return result.scalars().all()
