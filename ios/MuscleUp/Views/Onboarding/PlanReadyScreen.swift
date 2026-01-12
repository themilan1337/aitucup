//
//  PlanReadyScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct PlanReadyScreen: View {
    let onStartWorkout: () -> Void
    let onViewPlan: () -> Void
    @State private var animateContent = false
    @State private var animateConfetti = false

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            AnimatedGradientOverlay()

            // Success confetti effect
            if animateConfetti {
                ConfettiView()
            }

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Success Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.muscleUpAccent.opacity(0.3),
                                    Color.muscleUpAccent.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(animateContent ? 1.0 : 0.5)

                    ZStack {
                        Circle()
                            .fill(Color.muscleUpAccent)
                            .frame(width: 100, height: 100)

                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.muscleUpBackground)
                    }
                    .scaleEffect(animateContent ? 1.0 : 0.3)
                    .rotationEffect(.degrees(animateContent ? 0 : 180))
                }

                // Text Content
                VStack(spacing: Spacing.md) {
                    Text("Ваш план готов")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)

                    Text("Начните первую тренировку и отслеживайте прогресс каждый день.")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)

                Spacer()

                // Action Buttons
                VStack(spacing: Spacing.md) {
                    Button(action: onStartWorkout) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Начать тренировку")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button(action: onViewPlan) {
                        Text("Посмотреть план")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateContent = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateConfetti = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                animateConfetti = false
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [
            .muscleUpAccent,
            .pink,
            .orange,
            .purple,
            .blue
        ]

        for _ in 0..<30 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: -50...size.height * 0.3)
            let endY = size.height + 50
            let color = colors.randomElement() ?? .muscleUpAccent
            let size = CGFloat.random(in: 6...14)

            var piece = ConfettiPiece(
                position: CGPoint(x: x, y: y),
                color: color,
                size: size,
                opacity: 1.0
            )

            confettiPieces.append(piece)

            // Animate falling
            withAnimation(.easeIn(duration: Double.random(in: 1.5...2.5))) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].position.y = endY
                    confettiPieces[index].opacity = 0
                }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

#Preview {
    PlanReadyScreen(
        onStartWorkout: {},
        onViewPlan: {}
    )
}
