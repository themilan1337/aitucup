//
//  MuscleUpApp.swift
//  MuscleUp
//
//  Created by Bizhan on 12.01.2026.
//

import SwiftUI

@main
struct MuscleUpApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingContainerView()
            }
        }
    }
}
