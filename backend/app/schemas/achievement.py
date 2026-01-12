from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class AchievementResponse(BaseModel):
    id: UUID
    code: str
    title_ru: str
    description_ru: str
    icon: str
    requirement_type: str
    requirement_value: int

    class Config:
        from_attributes = True

class UserAchievementResponse(BaseModel):
    achievement: AchievementResponse
    unlocked_at: datetime

    class Config:
        from_attributes = True
