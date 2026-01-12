//
//  ProfileView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var dataProvider = MockDataProvider.shared
    @State private var animateContent = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Profile Header
                    profileHeader

                    // Quick Stats
                    quickStatsSection

                    // Achievements
                    achievementsSection

                    // Recent Workouts
                    recentWorkoutsSection

                    // Settings
                    settingsSection

                    // Logout Button
                    logoutButton
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.muscleUpBackground.ignoresSafeArea())
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.muscleUpAccent.opacity(0.4),
                                Color.muscleUpAccent.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.muscleUpAccent)
            }
            .scaleEffect(animateContent ? 1.0 : 0.8)

            // Name
            Text("Пользователь")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.muscleUpTextPrimary)

            // Member since
            Text("С нами с января 2025")
                .font(.muscleUpCaption)
                .foregroundColor(.muscleUpTextSecondary)

            // Edit profile button
            Button(action: {
                // TODO: Edit profile
            }) {
                Text("Редактировать профиль")
                    .font(.muscleUpCaptionBold)
                    .foregroundColor(.muscleUpAccent)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.muscleUpAccent.opacity(0.15))
                    .cornerRadius(CornerRadius.sm)
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : -20)
    }

    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        HStack(spacing: 0) {
            QuickStatItem(
                value: "\(dataProvider.userStats.totalWorkouts)",
                label: "Тренировок"
            )

            Divider()
                .frame(height: 40)
                .background(Color.muscleUpCardBorder)

            QuickStatItem(
                value: "\(dataProvider.userStats.totalReps)",
                label: "Повторений"
            )

            Divider()
                .frame(height: 40)
                .background(Color.muscleUpCardBorder)

            QuickStatItem(
                value: "\(Int(dataProvider.userStats.averageFormAccuracy * 100))%",
                label: "Точность"
            )
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateContent)
    }

    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.muscleUpAccent)
                Text("Достижения")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)

                Spacer()

                Text("\(dataProvider.achievements.filter { $0.isUnlocked }.count)/\(dataProvider.achievements.count)")
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.sm) {
                ForEach(dataProvider.achievements.prefix(6)) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }

    // MARK: - Recent Workouts
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.muscleUpAccent)
                Text("Последние тренировки")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)
            }

            ForEach(Array(dataProvider.workoutHistory.suffix(3).reversed())) { workout in
                WorkoutSummaryCard(workout: workout)
            }
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "person.circle", title: "Личные данные", showChevron: true) {}
            SettingsDivider()

            SettingsRow(icon: "bell", title: "Уведомления", showChevron: true) {}
            SettingsDivider()

            SettingsRow(icon: "camera", title: "Настройки камеры", showChevron: true) {}
            SettingsDivider()

            SettingsRow(icon: "globe", title: "Язык", detail: "Русский", showChevron: true) {}
            SettingsDivider()

            SettingsRow(icon: "questionmark.circle", title: "Помощь и поддержка", showChevron: true) {}
            SettingsDivider()

            SettingsRow(icon: "info.circle", title: "О приложении", showChevron: true) {}
        }
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateContent)
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: {
            // Reset onboarding for demo purposes
            hasCompletedOnboarding = false
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Выйти")
            }
            .font(.muscleUpBodyMedium)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.red.opacity(0.1))
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
        .opacity(animateContent ? 1.0 : 0)
    }
}

// MARK: - Quick Stat Item
struct QuickStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.muscleUpAccent)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.muscleUpTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.muscleUpAccent.opacity(0.2) : Color.muscleUpCardBorder.opacity(0.5))
                    .frame(width: 60, height: 60)

                Image(systemName: achievement.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .muscleUpAccent : .muscleUpTextSecondary)
            }

            Text(achievement.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.muscleUpTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var detail: String = ""
    var showChevron: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.muscleUpAccent)
                    .frame(width: 28)

                Text(title)
                    .font(.muscleUpBody)
                    .foregroundColor(.muscleUpTextPrimary)

                Spacer()

                if !detail.isEmpty {
                    Text(detail)
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.muscleUpTextSecondary)
                }
            }
            .padding(Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Divider
struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(Color.muscleUpCardBorder)
            .padding(.leading, 56)
    }
}

#Preview {
    ProfileView()
}
