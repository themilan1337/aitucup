from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.services.stats_service import stats_service

router = APIRouter()

@router.get("/dashboard")
async def get_dashboard_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get aggregated stats for the home dashboard"""
    return await stats_service.get_user_dashboard_stats(db, str(current_user.id))

@router.get("/accuracy-trend")
async def get_accuracy_trend(
    days: int = 7,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get form accuracy trend data for charts"""
    return await stats_service.get_accuracy_trend(db, str(current_user.id), days=days)
