//
//  GoalSelectionScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct GoalSelectionScreen: View {
    @ObservedObject var onboardingState: OnboardingState
    let onContinue: () -> Void
    @State private var animateCards = false

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Какая у вас цель?")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Выберите основную цель тренировок")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xxl)

                // Goal Cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.md) {
                        ForEach(Array(FitnessGoal.allCases.enumerated()), id: \.element) { index, goal in
                            GoalCard(
                                goal: goal,
                                isSelected: onboardingState.selectedGoal == goal
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    onboardingState.selectedGoal = goal
                                }
                            }
                            .offset(y: animateCards ? 0 : 50)
                            .opacity(animateCards ? 1.0 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.1),
                                value: animateCards
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }

                // Continue Button
                Button(action: onContinue) {
                    HStack(spacing: Spacing.sm) {
                        Text("Продолжить")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: onboardingState.canProceedFromGoal))
                .disabled(!onboardingState.canProceedFromGoal)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

// MARK: - Goal Card
struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SelectionCard(isSelected: isSelected) {
                HStack(spacing: Spacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.muscleUpAccent.opacity(0.2) : Color.muscleUpCardBorder.opacity(0.5))
                            .frame(width: 56, height: 56)

                        Image(systemName: goal.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(isSelected ? Color.muscleUpAccent : Color.muscleUpTextSecondary)
                    }

                    // Title
                    Text(goal.title)
                        .font(.muscleUpSubheadline)
                        .foregroundColor(.muscleUpTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    // Checkmark
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.muscleUpAccent)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GoalSelectionScreen(
        onboardingState: OnboardingState(),
        onContinue: {}
    )
}
