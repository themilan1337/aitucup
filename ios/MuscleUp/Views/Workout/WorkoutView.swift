//
//  WorkoutView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct WorkoutView: View {
    @State private var isWorkoutActive = false
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            if isWorkoutActive {
                activeWorkoutView
            } else {
                preWorkoutView
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }

    // MARK: - Pre-Workout View
    private var preWorkoutView: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Camera Icon
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
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)

                    Circle()
                        .fill(Color.muscleUpAccent)
                        .frame(width: 120, height: 120)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.muscleUpBackground)
                }
                .scaleEffect(animateContent ? 1.0 : 0.8)
                .opacity(animateContent ? 1.0 : 0)

                // Instructions
                VStack(spacing: Spacing.md) {
                    Text("Готовы к тренировке?")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)

                    Text("Разместите устройство так, чтобы всё тело было в кадре")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)

                Spacer()

                // Setup Tips
                VStack(alignment: .leading, spacing: Spacing.md) {
                    SetupTipRow(icon: "light.max", text: "Обеспечьте хорошее освещение")
                    SetupTipRow(icon: "iphone.landscape", text: "Расположите телефон горизонтально")
                    SetupTipRow(icon: "figure.stand", text: "Встаньте на расстоянии 2-3 метра")
                }
                .padding(Spacing.lg)
                .background(Color.muscleUpCardBackground)
                .cornerRadius(CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
                )
                .padding(.horizontal, Spacing.lg)
                .opacity(animateContent ? 1.0 : 0)

                // Start Button
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isWorkoutActive = true
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Начать тренировку")
                    }
                    .font(.muscleUpBodyMedium)
                    .foregroundColor(.muscleUpBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.muscleUpAccent)
                    .cornerRadius(CornerRadius.md)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
                .opacity(animateContent ? 1.0 : 0)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Active Workout View (Camera Placeholder)
    private var activeWorkoutView: some View {
        ZStack {
            // Simulated camera feed background
            LinearGradient(
                colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Skeleton overlay simulation
            Image(systemName: "figure.stand")
                .font(.system(size: 200, weight: .ultraLight))
                .foregroundColor(.muscleUpAccent.opacity(0.3))

            VStack {
                // Top Bar
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isWorkoutActive = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }

                    Spacer()

                    // Timer
                    Text("0:00")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(CornerRadius.sm)
                }
                .padding(Spacing.lg)

                Spacer()

                // Rep Counter
                VStack(spacing: Spacing.sm) {
                    Text("0")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.muscleUpAccent)
                        .shadow(color: .black.opacity(0.5), radius: 4)

                    Text("ПОВТОРЕНИЙ")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                }
                .padding(Spacing.lg)
                .background(Color.black.opacity(0.3))
                .cornerRadius(CornerRadius.md)

                // Form Feedback
                HStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)

                    Text("Отличная форма!")
                        .font(.muscleUpBodyMedium)
                        .foregroundColor(.white)
                }
                .padding(Spacing.md)
                .background(Color.black.opacity(0.5))
                .cornerRadius(CornerRadius.md)
                .padding(.top, Spacing.lg)

                Spacer()

                // Bottom Controls
                HStack(spacing: Spacing.xl) {
                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isWorkoutActive = false
                        }
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
        .statusBar(hidden: true)
    }
}

// MARK: - Setup Tip Row
struct SetupTipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.muscleUpAccent)
                .frame(width: 32)

            Text(text)
                .font(.muscleUpBody)
                .foregroundColor(.muscleUpTextPrimary)

            Spacer()
        }
    }
}

#Preview {
    WorkoutView()
}
