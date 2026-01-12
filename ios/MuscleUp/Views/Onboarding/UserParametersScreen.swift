//
//  UserParametersScreen.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct UserParametersScreen: View {
    @ObservedObject var onboardingState: OnboardingState
    let onContinue: () -> Void
    @State private var animateContent = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case age, weight, height
    }

    var body: some View {
        ZStack {
            Color.muscleUpBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        Text("Немного о вас")
                            .font(.muscleUpHeadline)
                            .foregroundColor(.muscleUpTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Эти данные помогут персонализировать программу")
                            .font(.muscleUpBody)
                            .foregroundColor(.muscleUpTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.xxl)
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 30)

                    // Input Fields
                    VStack(spacing: Spacing.md) {
                        ParameterInputField(
                            icon: "calendar",
                            title: "Возраст",
                            placeholder: "25",
                            unit: "лет",
                            text: $onboardingState.age,
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .age)

                        ParameterInputField(
                            icon: "scalemass",
                            title: "Вес",
                            placeholder: "70",
                            unit: "кг",
                            text: $onboardingState.weight,
                            keyboardType: .decimalPad
                        )
                        .focused($focusedField, equals: .weight)

                        ParameterInputField(
                            icon: "ruler",
                            title: "Рост",
                            placeholder: "175",
                            unit: "см",
                            text: $onboardingState.height,
                            keyboardType: .numberPad
                        )
                        .focused($focusedField, equals: .height)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 30)

                    Spacer()
                        .frame(height: Spacing.xxl)

                    // Continue Button
                    Button(action: onContinue) {
                        HStack(spacing: Spacing.sm) {
                            Text("Продолжить")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: onboardingState.canProceedFromParameters))
                    .disabled(!onboardingState.canProceedFromParameters)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                    .opacity(animateContent ? 1.0 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateContent = true
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Parameter Input Field
struct ParameterInputField: View {
    let icon: String
    let title: String
    let placeholder: String
    let unit: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.muscleUpAccent)

                Text(title)
                    .font(.muscleUpCaptionBold)
                    .foregroundColor(.muscleUpTextSecondary)
            }

            // Input Container
            HStack(spacing: Spacing.md) {
                TextField(placeholder, text: $text)
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)
                    .keyboardType(keyboardType)
                    .frame(maxWidth: .infinity)

                Text(unit)
                    .font(.muscleUpBodyMedium)
                    .foregroundColor(.muscleUpTextSecondary)
            }
            .padding(Spacing.md)
            .background(Color.muscleUpCardBackground)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(
                        text.isEmpty ? Color.muscleUpCardBorder : Color.muscleUpAccent.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

#Preview {
    UserParametersScreen(
        onboardingState: OnboardingState(),
        onContinue: {}
    )
}
