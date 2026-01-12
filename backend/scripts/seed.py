import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import engine, AsyncSessionLocal
from app.models.achievement import Achievement
from sqlalchemy import select

async def seed_achievements():
    async with AsyncSessionLocal() as db:
        achievements = [
            Achievement(
                code="first_workout",
                title_ru="Первый шаг",
                title_en="First Step",
                description_ru="Выполнили свою первую тренировку!",
                description_en="Completed your first workout!",
                icon="figure.run",
                requirement_type="workout_count",
                requirement_value=1
            ),
            Achievement(
                code="streak_3",
                title_ru="Тройной удар",
                title_en="Triple Threat",
                description_ru="Тренируйтесь 3 дня подряд",
                description_en="Work out for 3 days in a row",
                icon="flame.fill",
                requirement_type="streak",
                requirement_value=3
            ),
            Achievement(
                code="reps_100",
                title_ru="Сотня",
                title_en="Centurion",
                description_ru="Выполнили 100 повторений суммарно",
                description_en="Completed 100 total repetitions",
                icon="star.fill",
                requirement_type="reps_total",
                requirement_value=100
            ),
            Achievement(
                code="perfect_form",
                title_ru="Мастер техники",
                title_en="Form Master",
                description_ru="Средняя точность тренировки выше 95%",
                description_en="Average workout accuracy above 95%",
                icon="checkmark.seal.fill",
                requirement_type="form_accuracy",
                requirement_value=95
            )
        ]

        for achievement in achievements:
            # Check if exists
            result = await db.execute(select(Achievement).filter(Achievement.code == achievement.code))
            if not result.scalars().first():
                db.add(achievement)
        
        await db.commit()
        print("Achievements seeded successfully!")

if __name__ == "__main__":
    asyncio.run(seed_achievements())
