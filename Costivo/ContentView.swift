//
//  ContentView.swift
//  Costivo
//
//  Created by Filip Kjamilov on 06.02.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var settings: [AppSettings]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showDebugConsole = false
    @State private var showPaywall = false
    @State private var onboardingComplete = false
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @AppStorage("hasPickedCurrency") private var hasPickedCurrency = false
    @AppStorage("walkthroughMigrationDone") private var walkthroughMigrationDone = false

    private var onboardingDone: Bool {
        hasSeenWalkthrough || onboardingComplete
    }

    var body: some View {
        Group {
            if onboardingDone && subscriptionManager.canAccessApp {
                TabView {
                    JobsView()
                        .tabItem {
                            Label(L(.jobs), systemImage: settings.handymanType.jobsIcon)
                        }

                    MaterialsView()
                        .tabItem {
                            Label(L(.materialsTitle), systemImage: settings.handymanType.materialsIcon)
                        }

                    SettingsView()
                        .tabItem {
                            Label(L(.settings), systemImage: settings.handymanType.settingsIcon)
                        }
                }
            } else if onboardingDone {
                // Trial expired or not subscribed — block with paywall
                PaywallView(isDismissible: false)
            } else {
                OnboardingView {
                    onboardingComplete = true
                }
            }
        }
        .sheet(isPresented: $showDebugConsole) {
            DebugConsoleView()
        }
        #if DEBUG || QA_BUILD
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            showDebugConsole = true
        }
        #endif
        .onAppear {
            // One-time migration: existing users who completed onboarding
            // before the walkthrough was added skip it automatically.
            if !walkthroughMigrationDone {
                walkthroughMigrationDone = true
                if hasPickedCurrency && !hasSeenWalkthrough {
                    hasSeenWalkthrough = true
                }
            }

            // Existing users get a fresh 14-day trial from the update date
            if hasSeenWalkthrough {
                subscriptionManager.startTrial()
            }
        }
    }
}

#Preview("English") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )
    
    return ContentView()
        .modelContainer(container)
        .environment(SubscriptionManager())
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Macedonian") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )

    return ContentView()
        .modelContainer(container)
        .environment(SubscriptionManager())
        .environment(\.locale, Locale(identifier: "mk"))
}

