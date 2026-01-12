//
//  HomeView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var dataProvider = MockDataProvider.shared
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Welcome Header
                    welcomeHeader

                    // Streak Card
                    streakCard

                    // Today's Workout
                    todaysWorkoutSection

                    // Weekly Stats
                    weeklyStatsSection

                    // Quick Stats Grid
                    quickStatsGrid
                }
                .padding(Spacing.md)
                .padding(.bottom, 100) // Space for tab bar
            }
            .background(Color.muscleUpBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }

    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Добро пожаловать!")
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)

                Text("Время тренироваться")
                    .font(.muscleUpHeadline)
                    .foregroundColor(.muscleUpTextPrimary)
            }

            Spacer()

            // User Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.muscleUpAccent.opacity(0.3), Color.muscleUpAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: "person.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.muscleUpAccent)
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : -20)
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.muscleUpAccent.opacity(0.15),
                            Color.muscleUpAccent.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: Spacing.md) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(Color.muscleUpAccent)
                        .frame(width: 56, height: 56)

                    Text("🔥")
                        .font(.system(size: 32))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(dataProvider.userStats.currentStreak)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.muscleUpAccent)

                        Text("дней подряд!")
                            .font(.muscleUpSubheadline)
                            .foregroundColor(.muscleUpTextPrimary)
                    }

                    Text("Продолжайте в том же духе")
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                }

                Spacer()
            }
            .padding(Spacing.md)
        }
        .frame(height: 100)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpAccent.opacity(0.3), lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .scaleEffect(animateContent ? 1.0 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateContent)
    }

    // MARK: - Today's Workout Section
    private var todaysWorkoutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Сегодняшняя тренировка")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            if let todayPlan = dataProvider.getTodaysPlan() {
                if todayPlan.isRestDay {
                    restDayCard
                } else {
                    workoutPreviewCard(todayPlan)
                }
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }

    private var restDayCard: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 40))
                .foregroundColor(.muscleUpAccent.opacity(0.6))

            Text("День отдыха")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            Text("Восстанавливайте силы для следующей тренировки")
                .font(.muscleUpCaption)
                .foregroundColor(.muscleUpTextSecondary)
                .multilineTextAlignment(.center)
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

    private func workoutPreviewCard(_ plan: PlanDay) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Exercises list
            ForEach(plan.exercises) { exercise in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: exercise.exerciseType.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.muscleUpAccent)
                        .frame(width: 24)

                    Text(exercise.exerciseType.rawValue)
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextPrimary)

                    Spacer()

                    Text("\(exercise.targetSets) × \(exercise.targetReps)")
                        .font(.muscleUpCaptionBold)
                        .foregroundColor(.muscleUpTextSecondary)
                }
            }

            Divider()
                .background(Color.muscleUpCardBorder)

            HStack {
                Label {
                    Text("\(plan.estimatedDuration) мин")
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                } icon: {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.muscleUpAccent)
                        .font(.system(size: 12))
                }

                Spacer()

                Label {
                    Text(plan.focusArea)
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                } icon: {
                    Image(systemName: "target")
                        .foregroundColor(.muscleUpAccent)
                        .font(.system(size: 12))
                }
            }

            // Start button
            Button(action: {
                // TODO: Navigate to workout screen
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Начать тренировку")
                }
                .font(.muscleUpBodyMedium)
                .foregroundColor(.muscleUpBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.muscleUpAccent)
                .cornerRadius(CornerRadius.md)
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

    // MARK: - Weekly Stats Section
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Эта неделя")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)

                Spacer()

                Text("6 из 7 дней")
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)
            }

            let weekStats = dataProvider.getWeeklyStats()

            HStack(spacing: Spacing.sm) {
                StatCard(
                    icon: "dumbbell.fill",
                    value: "\(weekStats.workouts)",
                    label: "Тренировок"
                )

                StatCard(
                    icon: "flame.fill",
                    value: "\(Int(weekStats.calories))",
                    label: "Калорий"
                )
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
    }

    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Общая статистика")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(dataProvider.userStats.totalWorkouts)",
                    label: "Всего тренировок"
                )

                StatCard(
                    icon: "arrow.up.right.circle.fill",
                    value: "\(dataProvider.userStats.totalReps)",
                    label: "Всего повторений"
                )

                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(dataProvider.userStats.averageFormAccuracy * 100))%",
                    label: "Средняя точность"
                )

                StatCard(
                    icon: "trophy.fill",
                    value: "\(dataProvider.userStats.longestStreak)",
                    label: "Лучшая серия",
                    accentColor: .orange
                )
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateContent)
    }
}

#Preview {
    HomeView()
}
