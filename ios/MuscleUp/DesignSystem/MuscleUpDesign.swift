//
//  MuscleUpDesign.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

// MARK: - Color Palette
extension Color {
    static let muscleUpBackground = Color(hex: "000000")
    static let muscleUpAccent = Color(hex: "D4FF00")
    static let muscleUpCardBackground = Color(hex: "1C1C1E")
    static let muscleUpCardBorder = Color(hex: "2C2C2E")
    static let muscleUpTextPrimary = Color(hex: "FFFFFF")
    static let muscleUpTextSecondary = Color(hex: "ADADAD")
    static let muscleUpTextTertiary = Color(hex: "6E6E6E")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
extension Font {
    static let muscleUpTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let muscleUpHeadline = Font.system(size: 28, weight: .bold, design: .rounded)
    static let muscleUpSubheadline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let muscleUpBody = Font.system(size: 17, weight: .regular, design: .default)
    static let muscleUpBodyMedium = Font.system(size: 17, weight: .medium, design: .default)
    static let muscleUpCaption = Font.system(size: 15, weight: .regular, design: .default)
    static let muscleUpCaptionBold = Font.system(size: 15, weight: .semibold, design: .default)
}

// MARK: - Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.muscleUpBodyMedium)
            .foregroundColor(.muscleUpBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isEnabled ? Color.muscleUpAccent : Color.muscleUpCardBorder)
            .cornerRadius(CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.muscleUpBodyMedium)
            .foregroundColor(.muscleUpAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.muscleUpAccent, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Selection Card Style
struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let content: Content

    init(isSelected: Bool, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.muscleUpCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(
                        isSelected ? Color.muscleUpAccent : Color.muscleUpCardBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.muscleUpAccent.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 4
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientOverlay: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.muscleUpAccent.opacity(0.1),
                Color.muscleUpAccent.opacity(0.05),
                Color.clear
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Page Indicator
struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.muscleUpAccent : Color.muscleUpCardBorder)
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}
