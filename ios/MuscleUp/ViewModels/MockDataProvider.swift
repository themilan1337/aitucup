//
//  MockDataProvider.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import Foundation
import Combine

class MockDataProvider: ObservableObject {
    static let shared = MockDataProvider()

    @Published var workoutHistory: [WorkoutSession] = []
    @Published var weeklyPlan: [PlanDay] = []
    @Published var achievements: [Achievement] = []
    @Published var userStats: UserStats
    @Published var currentWeight: Double = 70.0

    init() {
        // Initialize with default stats
        self.userStats = UserStats()

        // Generate mock data
        generateWorkoutHistory()
        generateWeeklyPlan()
        generateAchievements()
        calculateUserStats()
    }

    // MARK: - Generate Mock Workout History
    private func generateWorkoutHistory() {
        let calendar = Calendar.current
        let today = Date()

        // Generate 20 workouts over the past 30 days
        let workoutDates: [Int] = [1, 2, 4, 5, 7, 9, 11, 12, 14, 16, 18, 19, 21, 23, 25, 26, 28, 29, 30]

        workoutHistory = workoutDates.compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }

            let exercises = generateRandomExercises(forDate: date)
            return WorkoutSession(date: date, exercises: exercises, isCompleted: true)
        }.reversed()
    }

    private func generateRandomExercises(forDate date: Date) -> [ExercisePerformance] {
        let exerciseTypes: [ExerciseType] = [.squat, .lunge, .pushup, .plank]
        let selectedExercises = exerciseTypes.shuffled().prefix(Int.random(in: 2...3))

        return selectedExercises.map { type in
            let reps: Int
            let duration: TimeInterval
            let formAccuracy = Double.random(in: 0.75...0.98)
            let corrections = Int.random(in: 0...5)

            switch type {
            case .squat:
                reps = Int.random(in: 15...30)
                duration = TimeInterval(reps * 3)
            case .lunge:
                reps = Int.random(in: 20...40)
                duration = TimeInterval(reps * 2)
            case .pushup:
                reps = Int.random(in: 10...25)
                duration = TimeInterval(reps * 3)
            case .plank:
                reps = 1
                duration = TimeInterval(Int.random(in: 30...120))
            }

            return ExercisePerformance(
                exerciseType: type,
                reps: reps,
                duration: duration,
                formAccuracy: formAccuracy,
                formCorrections: corrections
            )
        }
    }

    // MARK: - Generate Weekly Plan
    private func generateWeeklyPlan() {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2) // Adjust for Sunday = 1
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return }

        // Generate 7 days
        weeklyPlan = (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: monday) else { return nil }

            let isRestDay = (dayOffset == 2 || dayOffset == 5) // Wednesday and Saturday are rest days
            let isCompleted = date < today

            if isRestDay {
                return PlanDay(date: date, isRestDay: true, isCompleted: isCompleted)
            }

            let exercises = generatePlannedExercises(forDay: dayOffset)
            return PlanDay(date: date, exercises: exercises, isCompleted: isCompleted)
        }
    }

    private func generatePlannedExercises(forDay day: Int) -> [PlannedExercise] {
        switch day {
        case 0: // Monday - Legs
            return [
                PlannedExercise(exerciseType: .squat, targetSets: 3, targetReps: 20, estimatedMinutes: 8),
                PlannedExercise(exerciseType: .lunge, targetSets: 3, targetReps: 15, estimatedMinutes: 7)
            ]
        case 1: // Tuesday - Upper Body
            return [
                PlannedExercise(exerciseType: .pushup, targetSets: 3, targetReps: 15, estimatedMinutes: 6),
                PlannedExercise(exerciseType: .plank, targetSets: 3, targetReps: 1, estimatedMinutes: 5)
            ]
        case 3: // Thursday - Full Body
            return [
                PlannedExercise(exerciseType: .squat, targetSets: 2, targetReps: 15, estimatedMinutes: 5),
                PlannedExercise(exerciseType: .pushup, targetSets: 2, targetReps: 12, estimatedMinutes: 4),
                PlannedExercise(exerciseType: .plank, targetSets: 2, targetReps: 1, estimatedMinutes: 4)
            ]
        case 4: // Friday - Legs
            return [
                PlannedExercise(exerciseType: .lunge, targetSets: 3, targetReps: 20, estimatedMinutes: 8),
                PlannedExercise(exerciseType: .squat, targetSets: 2, targetReps: 15, estimatedMinutes: 5)
            ]
        case 6: // Sunday - Core
            return [
                PlannedExercise(exerciseType: .plank, targetSets: 4, targetReps: 1, estimatedMinutes: 8),
                PlannedExercise(exerciseType: .pushup, targetSets: 3, targetReps: 15, estimatedMinutes: 6)
            ]
        default:
            return []
        }
    }

    // MARK: - Generate Achievements
    private func generateAchievements() {
        achievements = [
            Achievement(
                title: "Первая тренировка",
                description: "Завершите первую тренировку",
                icon: "star.fill",
                isUnlocked: true,
                unlockedDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())
            ),
            Achievement(
                title: "Серия 7 дней",
                description: "Тренируйтесь 7 дней подряд",
                icon: "flame.fill",
                isUnlocked: true,
                unlockedDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())
            ),
            Achievement(
                title: "100 повторений",
                description: "Выполните 100 повторений за тренировку",
                icon: "100.circle.fill",
                isUnlocked: true,
                unlockedDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())
            ),
            Achievement(
                title: "Мастер формы",
                description: "Достигните 95% точности формы",
                icon: "checkmark.seal.fill",
                isUnlocked: true,
                unlockedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())
            ),
            Achievement(
                title: "20 тренировок",
                description: "Завершите 20 тренировок",
                icon: "trophy.fill",
                isUnlocked: false
            ),
            Achievement(
                title: "Серия 30 дней",
                description: "Тренируйтесь 30 дней подряд",
                icon: "flame.circle.fill",
                isUnlocked: false
            )
        ]
    }

    // MARK: - Calculate User Stats
    private func calculateUserStats() {
        let totalWorkouts = workoutHistory.count
        let totalReps = workoutHistory.reduce(0) { $0 + $1.totalReps }
        let totalCalories = workoutHistory.reduce(0) { $0 + $1.totalCalories }
        let totalMinutes = Int(workoutHistory.reduce(0) { $0 + $1.totalDuration } / 60)
        let averageFormAccuracy = workoutHistory.isEmpty ? 0 : workoutHistory.reduce(0) { $0 + $1.averageFormAccuracy } / Double(totalWorkouts)

        // Calculate current streak
        let currentStreak = calculateCurrentStreak()
        let longestStreak = calculateLongestStreak()

        // Calculate personal records
        var personalRecords: [ExerciseType: Int] = [:]
        for type in ExerciseType.allCases {
            let maxReps = workoutHistory
                .flatMap { $0.exercises }
                .filter { $0.exerciseType == type }
                .map { $0.reps }
                .max() ?? 0
            personalRecords[type] = maxReps
        }

        userStats = UserStats(
            totalWorkouts: totalWorkouts,
            totalReps: totalReps,
            totalCalories: totalCalories,
            totalMinutes: totalMinutes,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageFormAccuracy: averageFormAccuracy,
            personalRecords: personalRecords
        )
    }

    private func calculateCurrentStreak() -> Int {
        guard !workoutHistory.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today

        // Sort workouts by date descending
        let sortedWorkouts = workoutHistory.sorted { $0.date > $1.date }

        for workout in sortedWorkouts {
            let workoutDate = calendar.startOfDay(for: workout.date)
            let daysDifference = calendar.dateComponents([.day], from: workoutDate, to: currentDate).day ?? 0

            if daysDifference == 0 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if daysDifference == 1 {
                streak += 1
                currentDate = workoutDate
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }

    private func calculateLongestStreak() -> Int {
        guard !workoutHistory.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedWorkouts = workoutHistory.sorted { $0.date < $1.date }

        var longestStreak = 0
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: sortedWorkouts[0].date)

        for i in 1..<sortedWorkouts.count {
            let currentDate = calendar.startOfDay(for: sortedWorkouts[i].date)
            let daysDifference = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0

            if daysDifference == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysDifference > 1 {
                currentStreak = 1
            }

            previousDate = currentDate
        }

        return max(longestStreak, currentStreak)
    }

    // MARK: - Helper Methods
    func getWeeklyStats() -> (workouts: Int, reps: Int, calories: Double, minutes: Int) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        let weekWorkouts = workoutHistory.filter { $0.date >= weekAgo }
        let workouts = weekWorkouts.count
        let reps = weekWorkouts.reduce(0) { $0 + $1.totalReps }
        let calories = weekWorkouts.reduce(0) { $0 + $1.totalCalories }
        let minutes = Int(weekWorkouts.reduce(0) { $0 + $1.totalDuration } / 60)

        return (workouts, reps, calories, minutes)
    }

    func getTodaysPlan() -> PlanDay? {
        let calendar = Calendar.current
        return weeklyPlan.first { calendar.isDateInToday($0.date) }
    }
}
