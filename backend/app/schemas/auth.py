"""Authentication schemas"""

from pydantic import BaseModel, EmailStr, Field, ConfigDict, field_serializer
from typing import Optional
from uuid import UUID
from datetime import datetime


class OAuthLoginRequest(BaseModel):
    """OAuth login request with CSRF protection and Remember Me"""
    id_token: str
    provider: str  # 'google'
    csrf_token: str  # CSRF protection
    remember_me: bool = False  # 30-day refresh token if True


class CSRFTokenResponse(BaseModel):
    """CSRF token response"""
    csrf_token: str


class LogoutResponse(BaseModel):
    """Logout response"""
    message: str


class UserProfileResponse(BaseModel):
    """User profile data"""
    model_config = ConfigDict(from_attributes=True)

    age: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[int] = None
    fitness_goal: Optional[str] = None
    fitness_level: Optional[str] = None
    preferred_units: str = "metric"
    language: str = "ru"
    notifications_enabled: bool = True


class UserResponse(BaseModel):
    """User data response (NO tokens in body - they're in HttpOnly cookies)"""
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    full_name: Optional[str]
    avatar_url: Optional[str]
    oauth_provider: str
    created_at: datetime
    profile: Optional[UserProfileResponse] = None

    @field_serializer('id')
    def serialize_id(self, value: UUID) -> str:
        """Convert UUID to string"""
        return str(value)

    @field_serializer('created_at')
    def serialize_created_at(self, value: datetime) -> str:
        """Convert datetime to ISO format string"""
        return value.isoformat()
