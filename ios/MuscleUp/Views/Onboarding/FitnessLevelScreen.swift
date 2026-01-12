//
//  FitnessLevelScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct FitnessLevelScreen: View {
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
                    Text("Ваш уровень подготовки")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Это поможет подобрать оптимальную нагрузку")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xxl)

                // Level Cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.md) {
                        ForEach(Array(FitnessLevel.allCases.enumerated()), id: \.element) { index, level in
                            FitnessLevelCard(
                                level: level,
                                isSelected: onboardingState.selectedLevel == level
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    onboardingState.selectedLevel = level
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
                .buttonStyle(PrimaryButtonStyle(isEnabled: onboardingState.canProceedFromLevel))
                .disabled(!onboardingState.canProceedFromLevel)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

// MARK: - Fitness Level Card
struct FitnessLevelCard: View {
    let level: FitnessLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SelectionCard(isSelected: isSelected) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.muscleUpAccent.opacity(0.2) : Color.muscleUpCardBorder.opacity(0.5))
                                .frame(width: 48, height: 48)

                            Image(systemName: level.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(isSelected ? Color.muscleUpAccent : Color.muscleUpTextSecondary)
                        }

                        // Title
                        Text(level.title)
                            .font(.muscleUpSubheadline)
                            .foregroundColor(.muscleUpTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Checkmark
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.muscleUpAccent)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }

                    // Description
                    Text(level.description)
                        .font(.muscleUpCaption)
                        .foregroundColor(.muscleUpTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FitnessLevelScreen(
        onboardingState: OnboardingState(),
        onContinue: {}
    )
}
