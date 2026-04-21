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
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("hasPickedProfession") private var hasPickedProfession = false
    @AppStorage("hasPickedCurrency") private var hasPickedCurrency = false
    private let isQABuild = ProcessInfo.processInfo.environment["IS_QA_BUILD"] == "YES"

    var body: some View {
        Group {
            if !hasSeenTutorial {
                TutorialView {
                    withAnimation {
                        hasSeenTutorial = true
                    }
                }
            } else if !hasPickedProfession {
                ProfessionPickerView {
                    withAnimation {
                        hasPickedProfession = true
                    }
                }
            } else if !hasPickedCurrency {
                CurrencyPickerView {
                    withAnimation {
                        hasPickedCurrency = true
                    }
                }
            } else {
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
            }
        }
        .sheet(isPresented: $showDebugConsole) {
            DebugConsoleView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake)) { _ in
            if isQABuild {
                showDebugConsole = true
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

