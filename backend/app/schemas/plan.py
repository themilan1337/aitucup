from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum

class ExerciseType(str, Enum):
    SQUAT = "Приседания"
    LUNGE = "Выпады"
    PUSHUP = "Отжимания"
    PLANK = "Планка"

class PlannedExercise(BaseModel):
    exercise_type: ExerciseType
    sets: int
    reps: Optional[int] = None
    duration: Optional[int] = None  # in seconds for plank
    instructions: str

class PlanDay(BaseModel):
    day_number: int # 1 to 7
    is_rest_day: bool = False
    exercises: List[PlannedExercise] = []
    daily_focus: str

class WeeklyPlanAI(BaseModel):
    title: str
    description: str
    days: List[PlanDay] = Field(..., min_items=7, max_items=7)

class UserProfileData(BaseModel):
    age: int
    weight: float
    height: int
    fitness_goal: str
    fitness_level: str
