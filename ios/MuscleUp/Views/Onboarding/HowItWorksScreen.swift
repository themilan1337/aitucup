//
//  HowItWorksScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct HowItWorksScreen: View {
    let onContinue: () -> Void
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Как работает\nMuscleUp Vision")
                        .font(.muscleUpHeadline)
                        .foregroundColor(.muscleUpTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(4)

                    Text("Технология компьютерного зрения для идеальной техники")
                        .font(.muscleUpBody)
                        .foregroundColor(.muscleUpTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xxl)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)

                // Features
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        ForEach(Array(HowItWorksFeature.features.enumerated()), id: \.element.id) { index, feature in
                            FeatureCard(
                                feature: feature,
                                index: index
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(x: animateContent ? 0 : -30)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(0.2 + Double(index) * 0.15),
                                value: animateContent
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
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
                .opacity(animateContent ? 1.0 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let feature: HowItWorksFeature
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Number Badge
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(Color.muscleUpAccent)
                    .frame(width: 48, height: 48)

                Text("\(index + 1)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.muscleUpBackground)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.muscleUpAccent)

                    Text(feature.title)
                        .font(.muscleUpSubheadline)
                        .foregroundColor(.muscleUpTextPrimary)
                }

                Text(feature.description)
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    HowItWorksScreen(onContinue: {})
}
