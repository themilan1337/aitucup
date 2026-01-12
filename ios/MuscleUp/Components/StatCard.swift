//
//  StatCard.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let trend: TrendIndicator?
    let accentColor: Color

    enum TrendIndicator {
        case up(String)
        case down(String)
        case neutral

        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .muscleUpTextSecondary
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }

        var text: String {
            switch self {
            case .up(let value): return value
            case .down(let value): return value
            case .neutral: return ""
            }
        }
    }

    init(icon: String,
         value: String,
         label: String,
         trend: TrendIndicator? = nil,
         accentColor: Color = .muscleUpAccent) {
        self.icon = icon
        self.value = value
        self.label = label
        self.trend = trend
        self.accentColor = accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)

                Spacer()

                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.system(size: 10, weight: .bold))
                        if !trend.text.isEmpty {
                            Text(trend.text)
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(trend.color)
                }
            }

            Spacer()

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.muscleUpTextPrimary)

            Text(label)
                .font(.muscleUpCaption)
                .foregroundColor(.muscleUpTextSecondary)
        }
        .padding(Spacing.md)
        .frame(height: 120)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Metric Card (with mini chart)
struct MetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let chartData: [Double]?
    let accentColor: Color

    init(icon: String,
         value: String,
         unit: String,
         label: String,
         chartData: [Double]? = nil,
         accentColor: Color = .muscleUpAccent) {
        self.icon = icon
        self.value = value
        self.unit = unit
        self.label = label
        self.chartData = chartData
        self.accentColor = accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)

                Text(label)
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.muscleUpTextPrimary)

                Text(unit)
                    .font(.muscleUpCaption)
                    .foregroundColor(.muscleUpTextSecondary)
            }

            if let chartData = chartData {
                MiniLineChart(data: chartData, color: accentColor)
                    .frame(height: 30)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Mini Line Chart
struct MiniLineChart: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let minValue = data.min() ?? 0
            let range = maxValue - minValue

            Path { path in
                guard data.count > 1, range > 0 else { return }

                let stepX = geometry.size.width / CGFloat(data.count - 1)

                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedValue = (value - minValue) / range
                    let y = geometry.size.height * (1 - CGFloat(normalizedValue))

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double // 0.0 - 1.0
    let lineWidth: CGFloat
    let accentColor: Color

    init(progress: Double, lineWidth: CGFloat = 12, accentColor: Color = .muscleUpAccent) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.accentColor = accentColor
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.muscleUpCardBorder, lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview("StatCard") {
    StatCard(
        icon: "flame.fill",
        value: "8",
        label: "Текущая серия",
        trend: .up("+2")
    )
    .frame(width: 160)
    .padding()
    .background(Color.muscleUpBackground)
}

#Preview("MetricCard") {
    MetricCard(
        icon: "figure.run",
        value: "245",
        unit: "повт",
        label: "Всего повторений",
        chartData: [10, 15, 12, 18, 20, 17, 22]
    )
    .frame(width: 180)
    .padding()
    .background(Color.muscleUpBackground)
}
