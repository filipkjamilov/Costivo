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
    @State private var showDebugConsole = false
    @State private var onboardingComplete = false
    @AppStorage("hasPickedCurrency") private var hasPickedCurrency = false

    var body: some View {
        Group {
            if hasPickedCurrency || onboardingComplete {
                TabView {
                    JobsView()
                        .tabItem {
                            Label("Jobs", systemImage: settings.handymanType.jobsIcon)
                        }

                    MaterialsView()
                        .tabItem {
                            Label("Materials", systemImage: settings.handymanType.materialsIcon)
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: settings.handymanType.settingsIcon)
                        }
                }
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
        .environment(\.locale, Locale(identifier: "mk"))
}

