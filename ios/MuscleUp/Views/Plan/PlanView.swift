//
//  PlanView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct PlanView: View {
    @ObservedObject var dataProvider = MockDataProvider.shared
    @State private var selectedDay: PlanDay?
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Weekly Calendar
                    weeklyCalendar

                    // Today's Plan Details
                    if let todayPlan = dataProvider.getTodaysPlan() {
                        todaysPlanSection(todayPlan)
                    }

                    // Exercise Library
                    exerciseLibrarySection
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.muscleUpBackground.ignoresSafeArea())
            .navigationTitle("План")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }

    // MARK: - Weekly Calendar
    private var weeklyCalendar: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Эта неделя")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(dataProvider.weeklyPlan) { day in
                        CalendarDayCard(day: day, isSelected: selectedDay?.id == day.id) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDay = day
                            }
                        }
                    }
                }
            }
        }
        .opacity(animateContent ? 1.0 : 0)
    }

    // MARK: - Today's Plan Section
    private func todaysPlanSection(_ plan: PlanDay) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.muscleUpAccent)
                Text("Сегодняшняя тренировка")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)
            }

            if plan.isRestDay {
                RestDayCard()
            } else {
                VStack(spacing: Spacing.md) {
                    // Exercises
                    ForEach(plan.exercises) { exercise in
                        ExercisePlanRow(exercise: exercise)
                    }

                    Divider()
                        .background(Color.muscleUpCardBorder)

                    // Summary
                    HStack {
                        Label {
                            Text("\(plan.estimatedDuration) мин")
                                .font(.muscleUpCaption)
                                .foregroundColor(.muscleUpTextSecondary)
                        } icon: {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.muscleUpAccent)
                        }

                        Spacer()

                        Label {
                            Text(plan.focusArea)
                                .font(.muscleUpCaption)
                                .foregroundColor(.muscleUpTextSecondary)
                        } icon: {
                            Image(systemName: "target")
                                .foregroundColor(.muscleUpAccent)
                        }

                        Spacer()

                        Label {
                            Text("\(plan.exercises.count) упражнения")
                                .font(.muscleUpCaption)
                                .foregroundColor(.muscleUpTextSecondary)
                        } icon: {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.muscleUpAccent)
                        }
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
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateContent)
    }

    // MARK: - Exercise Library Section
    private var exerciseLibrarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.muscleUpAccent)
                Text("Библиотека упражнений")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(ExerciseType.allCases, id: \.self) { exercise in
                    ExerciseCard(exercise: exercise) {
                        // TODO: Show exercise detail
                    }
                }
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }
}

// MARK: - Calendar Day Card
struct CalendarDayCard: View {
    let day: PlanDay
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                // Day name
                Text(dayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isToday ? .muscleUpAccent : .muscleUpTextSecondary)

                // Day number
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 48, height: 48)

                    if day.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    } else if day.isRestDay {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.muscleUpTextSecondary)
                    } else {
                        Text("\(dayNumber)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(textColor)
                    }
                }

                // Indicator dots
                if !day.isRestDay && !day.isCompleted {
                    HStack(spacing: 2) {
                        ForEach(0..<min(day.exercises.count, 3), id: \.self) { _ in
                            Circle()
                                .fill(Color.muscleUpAccent)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .padding(.vertical, Spacing.sm)
            .frame(width: 70)
            .background(
                isSelected ? Color.muscleUpCardBackground : Color.clear
            )
            .cornerRadius(CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .strokeBorder(
                        isSelected ? Color.muscleUpAccent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date).uppercased()
    }

    private var dayNumber: Int {
        Calendar.current.component(.day, from: day.date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(day.date)
    }

    private var backgroundColor: Color {
        if isToday {
            return Color.muscleUpAccent.opacity(0.2)
        } else if day.isCompleted {
            return Color.green.opacity(0.2)
        } else if day.isRestDay {
            return Color.muscleUpCardBorder
        } else {
            return Color.muscleUpCardBackground
        }
    }

    private var textColor: Color {
        if isToday {
            return .muscleUpAccent
        } else {
            return .muscleUpTextPrimary
        }
    }
}

// MARK: - Exercise Plan Row
struct ExercisePlanRow: View {
    let exercise: PlannedExercise

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Exercise icon
            ZStack {
                Circle()
                    .fill(Color.muscleUpAccent.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: exercise.exerciseType.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.muscleUpAccent)
            }

            // Exercise info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseType.rawValue)
                    .font(.muscleUpBodyMedium)
                    .foregroundColor(.muscleUpTextPrimary)

                Text(exercise.exerciseType.targetMuscles)
                    .font(.system(size: 12))
                    .foregroundColor(.muscleUpTextSecondary)
            }

            Spacer()

            // Sets and reps
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(exercise.targetSets) × \(exercise.targetReps)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.muscleUpAccent)

                Text("~\(exercise.estimatedMinutes) мин")
                    .font(.system(size: 11))
                    .foregroundColor(.muscleUpTextSecondary)
            }
        }
    }
}

// MARK: - Rest Day Card
struct RestDayCard: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 40))
                .foregroundColor(.muscleUpAccent.opacity(0.6))

            Text("День отдыха")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            Text("Дайте мышцам восстановиться")
                .font(.muscleUpCaption)
                .foregroundColor(.muscleUpTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    PlanView()
}
