//
//  WorkoutModels.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import Foundation

// MARK: - Exercise Type
enum ExerciseType: String, CaseIterable, Codable {
    case squat = "Приседания"
    case lunge = "Выпады"
    case pushup = "Отжимания"
    case plank = "Планка"

    var icon: String {
        switch self {
        case .squat: return "figure.strengthtraining.traditional"
        case .lunge: return "figure.walk"
        case .pushup: return "figure.mind.and.body"
        case .plank: return "figure.core.training"
        }
    }

    var targetMuscles: String {
        switch self {
        case .squat: return "Ноги, ягодицы"
        case .lunge: return "Ноги, ягодицы, баланс"
        case .pushup: return "Грудь, плечи, руки"
        case .plank: return "Кор, пресс"
        }
    }

    var difficulty: String {
        switch self {
        case .squat: return "Средний"
        case .lunge: return "Средний"
        case .pushup: return "Сложный"
        case .plank: return "Легкий"
        }
    }

    var caloriesPerRep: Double {
        switch self {
        case .squat: return 0.5
        case .lunge: return 0.6
        case .pushup: return 0.7
        case .plank: return 5.0 // per minute
        }
    }
}

// MARK: - Exercise Performance
struct ExercisePerformance: Identifiable, Codable {
    let id: UUID
    let exerciseType: ExerciseType
    let reps: Int
    let duration: TimeInterval // seconds
    let formAccuracy: Double // 0.0 - 1.0
    let formCorrections: Int
    let caloriesBurned: Double

    init(id: UUID = UUID(),
         exerciseType: ExerciseType,
         reps: Int,
         duration: TimeInterval,
         formAccuracy: Double,
         formCorrections: Int) {
        self.id = id
        self.exerciseType = exerciseType
        self.reps = reps
        self.duration = duration
        self.formAccuracy = max(0, min(1, formAccuracy))
        self.formCorrections = formCorrections

        // Calculate calories
        if exerciseType == .plank {
            self.caloriesBurned = (duration / 60.0) * exerciseType.caloriesPerRep
        } else {
            self.caloriesBurned = Double(reps) * exerciseType.caloriesPerRep
        }
    }
}

// MARK: - Workout Session
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let exercises: [ExercisePerformance]
    let totalDuration: TimeInterval
    let totalCalories: Double
    let averageFormAccuracy: Double
    let isCompleted: Bool

    init(id: UUID = UUID(),
         date: Date,
         exercises: [ExercisePerformance],
         isCompleted: Bool = true) {
        self.id = id
        self.date = date
        self.exercises = exercises
        self.totalDuration = exercises.reduce(0) { $0 + $1.duration }
        self.totalCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }
        self.averageFormAccuracy = exercises.isEmpty ? 0 : exercises.reduce(0) { $0 + $1.formAccuracy } / Double(exercises.count)
        self.isCompleted = isCompleted
    }

    var totalReps: Int {
        exercises.reduce(0) { $0 + $1.reps }
    }

    var totalCorrections: Int {
        exercises.reduce(0) { $0 + $1.formCorrections }
    }
}

// MARK: - Weekly Plan Day
struct PlanDay: Identifiable {
    let id: UUID
    let date: Date
    let exercises: [PlannedExercise]
    let isRestDay: Bool
    let isCompleted: Bool

    init(id: UUID = UUID(),
         date: Date,
         exercises: [PlannedExercise] = [],
         isRestDay: Bool = false,
         isCompleted: Bool = false) {
        self.id = id
        self.date = date
        self.exercises = exercises
        self.isRestDay = isRestDay
        self.isCompleted = isCompleted
    }

    var estimatedDuration: Int {
        exercises.reduce(0) { $0 + $1.estimatedMinutes }
    }

    var focusArea: String {
        let types = exercises.map { $0.exerciseType }
        if types.contains(.squat) || types.contains(.lunge) {
            return "Ноги"
        } else if types.contains(.pushup) {
            return "Верх тела"
        } else {
            return "Кор"
        }
    }
}

// MARK: - Planned Exercise
struct PlannedExercise: Identifiable {
    let id: UUID
    let exerciseType: ExerciseType
    let targetSets: Int
    let targetReps: Int
    let estimatedMinutes: Int

    init(id: UUID = UUID(),
         exerciseType: ExerciseType,
         targetSets: Int = 3,
         targetReps: Int = 15,
         estimatedMinutes: Int = 5) {
        self.id = id
        self.exerciseType = exerciseType
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.estimatedMinutes = estimatedMinutes
    }
}

// MARK: - Achievement Badge
struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?

    init(id: UUID = UUID(),
         title: String,
         description: String,
         icon: String,
         isUnlocked: Bool = false,
         unlockedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

// MARK: - User Stats Summary
struct UserStats {
    let totalWorkouts: Int
    let totalReps: Int
    let totalCalories: Double
    let totalMinutes: Int
    let currentStreak: Int
    let longestStreak: Int
    let averageFormAccuracy: Double
    let personalRecords: [ExerciseType: Int]

    init(totalWorkouts: Int = 0,
         totalReps: Int = 0,
         totalCalories: Double = 0,
         totalMinutes: Int = 0,
         currentStreak: Int = 0,
         longestStreak: Int = 0,
         averageFormAccuracy: Double = 0,
         personalRecords: [ExerciseType: Int] = [:]) {
        self.totalWorkouts = totalWorkouts
        self.totalReps = totalReps
        self.totalCalories = totalCalories
        self.totalMinutes = totalMinutes
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.averageFormAccuracy = averageFormAccuracy
        self.personalRecords = personalRecords
    }
}

// MARK: - Time Period
enum TimePeriod: String, CaseIterable {
    case week = "Неделя"
    case month = "Месяц"
    case all = "Всё время"
}
