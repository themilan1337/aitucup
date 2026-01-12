//
//  ExerciseCard.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: ExerciseType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.muscleUpAccent.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: exercise.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.muscleUpAccent)
                }

                // Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(exercise.rawValue)
                        .font(.muscleUpSubheadline)
                        .foregroundColor(.muscleUpTextPrimary)

                    Text(exercise.targetMuscles)
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                        .lineLimit(2)

                    // Difficulty badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(difficultyColor(exercise.difficulty))
                            .frame(width: 6, height: 6)

                        Text(exercise.difficulty)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.muscleUpTextSecondary)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.muscleUpCardBackground)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Легкий": return .green
        case "Средний": return .orange
        case "Сложный": return .red
        default: return .gray
        }
    }
}

// MARK: - Workout Summary Card
struct WorkoutSummaryCard: View {
    let workout: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Date header
            HStack {
                Text(formatDate(workout.date))
                    .font(.muscleUpCaptionBold)
                    .foregroundColor(.muscleUpTextSecondary)

                Spacer()

                // Completion checkmark
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                }
            }

            // Exercises list
            ForEach(workout.exercises) { exercise in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: exercise.exerciseType.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.muscleUpAccent)
                        .frame(width: 20)

                    Text(exercise.exerciseType.rawValue)
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextPrimary)

                    Spacer()

                    Text("\(exercise.reps) повт")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.muscleUpTextSecondary)
                }
            }

            Divider()
                .background(Color.muscleUpCardBorder)

            // Summary stats
            HStack(spacing: Spacing.lg) {
                StatPill(icon: "flame.fill", value: "\(Int(workout.totalCalories))", unit: "ккал")
                StatPill(icon: "clock.fill", value: formatDuration(workout.totalDuration), unit: "")
                StatPill(icon: "checkmark.seal.fill", value: "\(Int(workout.averageFormAccuracy * 100))", unit: "%")
            }
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Stat Pill (small inline stat)
struct StatPill: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.muscleUpAccent)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.muscleUpTextPrimary)

            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.muscleUpTextSecondary)
            }
        }
    }
}

#Preview("ExerciseCard") {
    ExerciseCard(exercise: .squat, onTap: {})
        .frame(width: 180)
        .padding()
        .background(Color.muscleUpBackground)
}
