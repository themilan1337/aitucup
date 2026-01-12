//
//  WelcomeScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct WelcomeScreen: View {
    let onContinue: () -> Void
    @State private var animateHero = false
    @State private var animateText = false
    @State private var animateButton = false

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            AnimatedGradientOverlay()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                // Hero Image with animated geometric overlay
                ZStack {
                    Image("hero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
                        .scaleEffect(animateHero ? 1.0 : 0.9)
                        .opacity(animateHero ? 1.0 : 0)

                    // Animated geometric overlays
                    GeometricOverlay()
                        .frame(height: 380)
                        .opacity(animateHero ? 0.6 : 0)
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()
                    .frame(height: Spacing.xxl)

                // Title
                VStack(spacing: Spacing.md) {
                    Text("Тренируйтесь правильно\nс помощью ИИ")
                        .font(.muscleUpTitle)
                        .foregroundColor(.muscleUpTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .offset(y: animateText ? 0 : 30)
                        .opacity(animateText ? 1.0 : 0)

                    Text("MuscleUp Vision анализирует технику упражнений через камеру и помогает выполнять тренировки безопасно и эффективно.")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, Spacing.lg)
                        .offset(y: animateText ? 0 : 30)
                        .opacity(animateText ? 1.0 : 0)
                }

                Spacer()

                // CTA Button
                Button(action: onContinue) {
                    HStack(spacing: Spacing.sm) {
                        Text("Начать")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
                .offset(y: animateButton ? 0 : 30)
                .opacity(animateButton ? 1.0 : 0)

                Spacer()
                    .frame(height: Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateHero = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3)) {
                animateText = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5)) {
                animateButton = true
            }
        }
    }
}

// MARK: - Geometric Overlay
struct GeometricOverlay: View {
    @State private var rotate1 = false
    @State private var rotate2 = false
    @State private var scale = false

    var body: some View {
        ZStack {
            // Infinity-like shape overlay
            InfinityShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.muscleUpAccent.opacity(0.8),
                            Color.muscleUpAccent.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .rotationEffect(.degrees(rotate1 ? 10 : -10))
                .scaleEffect(scale ? 1.05 : 0.95)

            InfinityShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.pink.opacity(0.6),
                            Color.orange.opacity(0.3)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    lineWidth: 3
                )
                .rotationEffect(.degrees(rotate2 ? -10 : 10))
                .scaleEffect(scale ? 0.95 : 1.05)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                rotate1.toggle()
                rotate2.toggle()
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                scale.toggle()
            }
        }
    }
}

// MARK: - Infinity Shape Path
struct InfinityShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2

        // Create infinity symbol path
        path.move(to: CGPoint(x: centerX, y: centerY))

        // Left loop
        path.addCurve(
            to: CGPoint(x: centerX * 0.3, y: centerY),
            control1: CGPoint(x: centerX * 0.8, y: centerY - height * 0.25),
            control2: CGPoint(x: centerX * 0.5, y: centerY - height * 0.25)
        )
        path.addCurve(
            to: CGPoint(x: centerX, y: centerY),
            control1: CGPoint(x: centerX * 0.1, y: centerY),
            control2: CGPoint(x: centerX * 0.2, y: centerY + height * 0.25)
        )

        // Right loop
        path.addCurve(
            to: CGPoint(x: centerX * 1.7, y: centerY),
            control1: CGPoint(x: centerX * 1.2, y: centerY - height * 0.25),
            control2: CGPoint(x: centerX * 1.5, y: centerY - height * 0.25)
        )
        path.addCurve(
            to: CGPoint(x: centerX, y: centerY),
            control1: CGPoint(x: centerX * 1.9, y: centerY),
            control2: CGPoint(x: centerX * 1.8, y: centerY + height * 0.25)
        )

        return path
    }
}

#Preview {
    WelcomeScreen(onContinue: {})
}
