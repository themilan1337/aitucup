//
//  MainTabView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: Int {
        case home = 0
        case progress = 1
        case workout = 2
        case plan = 3
        case profile = 4
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .progress:
                    ProgressView()
                case .workout:
                    WorkoutView()
                case .plan:
                    PlanView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "house.fill",
                title: "Главная",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            TabBarItem(
                icon: "chart.bar.fill",
                title: "Прогресс",
                isSelected: selectedTab == .progress
            ) {
                selectedTab = .progress
            }

            // Central Workout Button
            Button(action: {
                selectedTab = .workout
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.muscleUpAccent,
                                    Color.muscleUpAccent.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.muscleUpAccent.opacity(0.4), radius: 12, x: 0, y: 4)

                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.muscleUpBackground)
                }
            }
            .offset(y: -20)

            TabBarItem(
                icon: "calendar",
                title: "План",
                isSelected: selectedTab == .plan
            ) {
                selectedTab = .plan
            }

            TabBarItem(
                icon: "person.fill",
                title: "Профиль",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .background(
            Rectangle()
                .fill(Color.muscleUpBackground)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5)
        )
        .overlay(
            Rectangle()
                .fill(Color.muscleUpCardBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? .muscleUpAccent : .muscleUpTextSecondary)
                    .frame(height: 24)

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .muscleUpAccent : .muscleUpTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.0 : 0.95)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}
