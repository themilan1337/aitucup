//
//  OnboardingData.swift
//  MuscleUp
//
//  Created by MuscleUp Vision
//

import Foundation
import Combine

// MARK: - Fitness Goal
enum FitnessGoal: String, CaseIterable, Identifiable {
    case loseWeight = "lose_weight"
    case getToned = "get_toned"
    case improveShape = "improve_shape"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .loseWeight: return "Похудеть"
        case .getToned: return "Привести тело в тонус"
        case .improveShape: return "Улучшить физическую форму"
        }
    }

    var icon: String {
        switch self {
        case .loseWeight: return "flame.fill"
        case .getToned: return "figure.stand"
        case .improveShape: return "bolt.heart.fill"
        }
    }
}

// MARK: - Fitness Level
enum FitnessLevel: String, CaseIterable, Identifiable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner: return "Начальный"
        case .intermediate: return "Средний"
        case .advanced: return "Продвинутый"
        }
    }

    var description: String {
        switch self {
        case .beginner: return "Только начинаю"
        case .intermediate: return "Занимаюсь регулярно"
        case .advanced: return "Опытный спортсмен"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.circle.fill"
        }
    }
}

// MARK: - How It Works Feature
struct HowItWorksFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

extension HowItWorksFeature {
    static let features = [
        HowItWorksFeature(
            icon: "camera.fill",
            title: "Камера определяет положение тела",
            description: "Используя технологию компьютерного зрения"
        ),
        HowItWorksFeature(
            icon: "brain.head.profile",
            title: "ИИ анализирует технику",
            description: "Нейросеть оценивает правильность выполнения"
        ),
        HowItWorksFeature(
            icon: "checkmark.shield.fill",
            title: "Приложение подсказывает, если форма нарушена",
            description: "Получайте мгновенную обратную связь"
        )
    ]
}

// MARK: - Onboarding State
class OnboardingState: ObservableObject {
    @Published var selectedGoal: FitnessGoal?
    @Published var selectedLevel: FitnessLevel?
    @Published var age: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var currentPage: Int = 0
    @Published var isGeneratingPlan: Bool = false
    @Published var hasCompletedOnboarding: Bool = false

    var canProceedFromGoal: Bool {
        selectedGoal != nil
    }

    var canProceedFromLevel: Bool {
        selectedLevel != nil
    }

    var canProceedFromParameters: Bool {
        !age.isEmpty && !weight.isEmpty && !height.isEmpty
    }

    func generatePlan(completion: @escaping () -> Void) {
        isGeneratingPlan = true
        
        Task {
            do {
                // 1. Update user profile on backend
                let profileUpdate = ProfileUpdateRequest(
                    age: Int(age) ?? 0,
                    weight: Double(weight) ?? 0,
                    height: Int(height) ?? 0,
                    fitness_goal: selectedGoal?.rawValue ?? "",
                    fitness_level: selectedLevel?.rawValue ?? ""
                )
                
                let _: UserProfileResponse = try await APIClient.shared.request("users/profile", method: "PATCH", body: profileUpdate)
                
                // 2. Generate weekly plan using AI
                let _: PlanGenerationResponse = try await APIClient.shared.request("plans/generate", method: "POST")
                
                DispatchQueue.main.async {
                    self.isGeneratingPlan = false
                    completion()
                }
            } catch {
                print("Failed to generate plan: \(error)")
                DispatchQueue.main.async {
                    self.isGeneratingPlan = false
                    // Fallback to completion for demo purposes or show error
                    completion()
                }
            }
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct ProfileUpdateRequest: Encodable {
    let age: Int
    let weight: Double
    let height: Int
    let fitness_goal: String
    let fitness_level: String
}

struct UserProfileResponse: Decodable {
    let id: String
}

struct PlanGenerationResponse: Decodable {
    let status: String
    let plan_id: String
}
