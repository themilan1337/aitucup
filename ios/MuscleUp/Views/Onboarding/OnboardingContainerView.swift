//
//  OnboardingContainerView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var onboardingState = OnboardingState()
    @State private var currentStep: OnboardingStep = .welcome
    @Environment(\.dismiss) private var dismiss

    enum OnboardingStep {
        case welcome
        case goal
        case fitnessLevel
        case parameters
        case howItWorks
        case planGeneration
        case planReady
    }

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Bar
                if currentStep != .welcome && currentStep != .planGeneration && currentStep != .planReady {
                    OnboardingProgressBar(currentStep: currentStepIndex, totalSteps: 4)
                        .padding(.top, Spacing.md)
                        .padding(.horizontal, Spacing.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Content
                Group {
                    switch currentStep {
                    case .welcome:
                        WelcomeScreen(onContinue: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentStep = .goal
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .goal:
                        GoalSelectionScreen(
                            onboardingState: onboardingState,
                            onContinue: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep = .fitnessLevel
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .fitnessLevel:
                        FitnessLevelScreen(
                            onboardingState: onboardingState,
                            onContinue: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep = .parameters
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .parameters:
                        UserParametersScreen(
                            onboardingState: onboardingState,
                            onContinue: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep = .howItWorks
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .howItWorks:
                        HowItWorksScreen(onContinue: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentStep = .planGeneration
                            }
                        })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .planGeneration:
                        PlanGenerationScreen(
                            onboardingState: onboardingState,
                            onComplete: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep = .planReady
                                }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))

                    case .planReady:
                        PlanReadyScreen(
                            onStartWorkout: {
                                completeOnboarding()
                            },
                            onViewPlan: {
                                completeOnboarding()
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }

            // Back Button
            if showBackButton {
                VStack {
                    HStack {
                        Button(action: goBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.muscleUpTextPrimary)
                                .frame(width: 44, height: 44)
                                .background(Color.muscleUpCardBackground.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.leading, Spacing.md)
                        .padding(.top, Spacing.md)

                        Spacer()
                    }

                    Spacer()
                }
                .transition(.opacity)
            }
        }
    }

    private var currentStepIndex: Int {
        switch currentStep {
        case .welcome: return 0
        case .goal: return 1
        case .fitnessLevel: return 2
        case .parameters: return 3
        case .howItWorks: return 4
        case .planGeneration: return 5
        case .planReady: return 6
        }
    }

    private var showBackButton: Bool {
        switch currentStep {
        case .welcome, .planGeneration, .planReady:
            return false
        default:
            return true
        }
    }

    private func goBack() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch currentStep {
            case .goal:
                currentStep = .welcome
            case .fitnessLevel:
                currentStep = .goal
            case .parameters:
                currentStep = .fitnessLevel
            case .howItWorks:
                currentStep = .parameters
            default:
                break
            }
        }
    }

    private func completeOnboarding() {
        onboardingState.completeOnboarding()
        dismiss()
    }
}

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var progress: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Progress indicators
            HStack(spacing: Spacing.xs) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color.muscleUpAccent : Color.muscleUpCardBorder)
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                }
            }

            // Step counter
            Text("\(currentStep)/\(totalSteps)")
                .font(.muscleUpCaption)
                .foregroundColor(.muscleUpTextTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
    }
}

#Preview {
    OnboardingContainerView()
}
