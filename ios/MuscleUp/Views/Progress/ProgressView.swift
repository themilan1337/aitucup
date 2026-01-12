//
//  ProgressView.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import SwiftUI

struct ProgressView: View {
    @ObservedObject var dataProvider = MockDataProvider.shared
    @State private var selectedPeriod: TimePeriod = .week
    @State private var animateContent = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Period Selector
                    periodSelector

                    // Main Metrics Grid
                    metricsGrid

                    // Workout Frequency Chart
                    workoutFrequencyChart

                    // Form Accuracy Trend
                    formAccuracySection

                    // Personal Records
                    personalRecordsSection
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
            .background(Color.muscleUpBackground.ignoresSafeArea())
            .navigationTitle("Прогресс")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }

    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.muscleUpCaptionBold)
                        .foregroundColor(selectedPeriod == period ? .muscleUpBackground : .muscleUpTextSecondary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedPeriod == period ? Color.muscleUpAccent : Color.muscleUpCardBackground)
                        .cornerRadius(CornerRadius.sm)
                }
            }

            Spacer()
        }
        .opacity(animateContent ? 1.0 : 0)
    }

    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.sm) {
            MetricCard(
                icon: "dumbbell.fill",
                value: "\(dataProvider.userStats.totalWorkouts)",
                unit: "",
                label: "Тренировок",
                accentColor: .muscleUpAccent
            )

            MetricCard(
                icon: "arrow.up.right.circle.fill",
                value: "\(dataProvider.userStats.totalReps)",
                unit: "",
                label: "Повторений",
                chartData: generateRepsChartData(),
                accentColor: .muscleUpAccent
            )

            MetricCard(
                icon: "clock.fill",
                value: "\(dataProvider.userStats.totalMinutes)",
                unit: "мин",
                label: "Время",
                accentColor: .blue
            )

            MetricCard(
                icon: "flame.fill",
                value: "\(Int(dataProvider.userStats.totalCalories))",
                unit: "ккал",
                label: "Калорий",
                chartData: generateCaloriesChartData(),
                accentColor: .orange
            )

            MetricCard(
                icon: "checkmark.seal.fill",
                value: "\(Int(dataProvider.userStats.averageFormAccuracy * 100))",
                unit: "%",
                label: "Точность формы",
                chartData: generateFormAccuracyChartData(),
                accentColor: .green
            )

            MetricCard(
                icon: "scalemass.fill",
                value: String(format: "%.1f", dataProvider.currentWeight),
                unit: "кг",
                label: "Вес",
                accentColor: .purple
            )
        }
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateContent)
    }

    // MARK: - Workout Frequency Chart
    private var workoutFrequencyChart: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Частота тренировок")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            // Bar chart
            WeeklyBarChart(data: generateWeeklyWorkoutData())
                .frame(height: 200)
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }

    // MARK: - Form Accuracy Section
    private var formAccuracySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Динамика точности формы")
                .font(.muscleUpSubheadline)
                .foregroundColor(.muscleUpTextPrimary)

            // Line chart
            AccuracyLineChart(data: generateFullFormAccuracyData())
                .frame(height: 180)

            // Legend
            HStack(spacing: Spacing.lg) {
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Отлично (>90%)")
                        .font(.system(size: 11))
                        .foregroundColor(.muscleUpTextSecondary)
                }

                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Хорошо (80-90%)")
                        .font(.system(size: 11))
                        .foregroundColor(.muscleUpTextSecondary)
                }

                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Нужно улучшить (<80%)")
                        .font(.system(size: 11))
                        .foregroundColor(.muscleUpTextSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
    }

    // MARK: - Personal Records
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.muscleUpAccent)
                Text("Личные рекорды")
                    .font(.muscleUpSubheadline)
                    .foregroundColor(.muscleUpTextPrimary)
            }

            ForEach(ExerciseType.allCases, id: \.self) { exercise in
                if let record = dataProvider.userStats.personalRecords[exercise] {
                    HStack {
                        Image(systemName: exercise.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.muscleUpAccent)
                            .frame(width: 28)

                        Text(exercise.rawValue)
                            .font(.muscleUpBody)
                            .foregroundColor(.muscleUpTextPrimary)

                        Spacer()

                        Text("\(record)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.muscleUpAccent)

                        Text(exercise == .plank ? "сек" : "повт")
                            .font(.muscleUpCaption)
                            .foregroundColor(.muscleUpTextSecondary)
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.muscleUpCardBackground)
        .cornerRadius(CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.muscleUpCardBorder, lineWidth: 1)
        )
        .opacity(animateContent ? 1.0 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateContent)
    }

    // MARK: - Data Generators
    private func generateRepsChartData() -> [Double] {
        let recentWorkouts = Array(dataProvider.workoutHistory.suffix(7))
        return recentWorkouts.map { Double($0.totalReps) }
    }

    private func generateCaloriesChartData() -> [Double] {
        let recentWorkouts = Array(dataProvider.workoutHistory.suffix(7))
        return recentWorkouts.map { $0.totalCalories }
    }

    private func generateFormAccuracyChartData() -> [Double] {
        let recentWorkouts = Array(dataProvider.workoutHistory.suffix(7))
        return recentWorkouts.map { $0.averageFormAccuracy }
    }

    private func generateWeeklyWorkoutData() -> [WeekdayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2)
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }

        let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        var data: [WeekdayData] = []

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
            let workoutsOnDay = dataProvider.workoutHistory.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            data.append(WeekdayData(day: weekdays[i], count: workoutsOnDay.count))
        }

        return data
    }

    private func generateFullFormAccuracyData() -> [Double] {
        return dataProvider.workoutHistory.map { $0.averageFormAccuracy }
    }
}

// MARK: - Weekly Bar Chart
struct WeeklyBarChart: View {
    let data: [WeekdayData]

    var body: some View {
        GeometryReader { geometry in
            let maxValue = Double(data.map { $0.count }.max() ?? 1)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { item in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.muscleUpCardBorder.opacity(0.3))
                                .frame(height: geometry.size.height - 30)

                            // Value bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.muscleUpAccent)
                                .frame(height: max(4, (geometry.size.height - 30) * CGFloat(Double(item.count) / maxValue)))
                        }

                        Text(item.day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.muscleUpTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Accuracy Line Chart
struct AccuracyLineChart: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Reference lines
                ForEach([0.9, 0.8], id: \.self) { threshold in
                    Path { path in
                        let y = geometry.size.height * CGFloat(1 - threshold)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(
                        threshold == 0.9 ? Color.green.opacity(0.3) : Color.orange.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1, dash: [5])
                    )
                }

                // Line chart
                Path { path in
                    guard data.count > 1 else { return }

                    let stepX = geometry.size.width / CGFloat(data.count - 1)

                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height * CGFloat(1 - value)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.muscleUpAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height * CGFloat(1 - value)

                    Circle()
                        .fill(Color.muscleUpAccent)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Weekday Data Model
struct WeekdayData: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
}

#Preview {
    ProgressView()
}
