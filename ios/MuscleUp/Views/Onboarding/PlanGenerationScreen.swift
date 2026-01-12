//
//  PlanGenerationScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct PlanGenerationScreen: View {
    @ObservedObject var onboardingState: OnboardingState
    let onComplete: () -> Void
    @State private var animateLoader = false
    @State private var pulseAnimation = false
    @State private var rotationDegrees = 0.0

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            AnimatedGradientOverlay()

            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Animated Loader
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            Color.muscleUpCardBorder,
                            lineWidth: 8
                        )
                        .frame(width: 160, height: 160)

                    // Animated ring
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.muscleUpAccent,
                                    Color.muscleUpAccent.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(rotationDegrees))

                    // AI Icon
                    ZStack {
                        Circle()
                            .fill(Color.muscleUpAccent.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.muscleUpAccent)
                    }
                }
                .opacity(animateLoader ? 1.0 : 0)
                .scaleEffect(animateLoader ? 1.0 : 0.5)

                // Text Content
                VStack(spacing: Spacing.md) {
                    Text("Формируем ваш план\nтренировок")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("План создаётся на основе ваших целей и уровня подготовки")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)

                    // Status Text
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(Color.muscleUpAccent)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseAnimation ? 1.2 : 0.8)

                        Text("Подготовка плана...")
                            .font(.muscleUpCaptionBold)
                            .foregroundColor(.muscleUpAccent)
                    }
                    .padding(.top, Spacing.sm)
                }
                .opacity(animateLoader ? 1.0 : 0)
                .offset(y: animateLoader ? 0 : 30)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateLoader = true
            }

            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotationDegrees = 360
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }

            // Trigger plan generation
            onboardingState.generatePlan {
                onComplete()
            }
        }
    }
}

#Preview {
    PlanGenerationScreen(
        onboardingState: OnboardingState(),
        onComplete: {}
    )
}
