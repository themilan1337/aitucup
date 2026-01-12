from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.database import Base


class Achievement(Base):
    """Achievement definition"""

    __tablename__ = "achievements"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code = Column(String(100), unique=True, nullable=False, index=True)  # 'first_workout', 'streak_7', etc.

    # Localized titles
    title_ru = Column(String(255), nullable=False)
    title_en = Column(String(255), nullable=False)

    # Localized descriptions
    description_ru = Column(String, nullable=False)
    description_en = Column(String, nullable=False)

    # Display
    icon = Column(String(100), nullable=False)  # SF Symbol name

    # Requirements
    requirement_type = Column(String(50), nullable=False)  # 'workout_count', 'streak', 'reps_total', 'form_accuracy', etc.
    requirement_value = Column(Integer, nullable=False)

    # Relationships
    user_achievements = relationship("UserAchievement", back_populates="achievement", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Achievement(code={self.code}, type={self.requirement_type}, value={self.requirement_value})>"


class UserAchievement(Base):
    """User's unlocked achievements"""

    __tablename__ = "user_achievements"
    __table_args__ = (
        UniqueConstraint("user_id", "achievement_id", name="uq_user_achievement"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    achievement_id = Column(UUID(as_uuid=True), ForeignKey("achievements.id", ondelete="CASCADE"), nullable=False, index=True)
    unlocked_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="user_achievements")
    achievement = relationship("Achievement", back_populates="user_achievements")

    def __repr__(self):
        return f"<UserAchievement(user_id={self.user_id}, achievement_id={self.achievement_id})>"
