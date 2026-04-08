//
//  CostivoApp.swift
//  Costivo
//
//  Created by Filip Kjamilov on 06.02.26.
//

import SwiftUI
import SwiftData

@main
struct CostivoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self]) { result in
            if case .failure(let error) = result {
                print("Failed to initialize model container: \(error)")
                return
            }
            if case .success(let container) = result {
                SeedData.insertIfNeeded(into: container.mainContext)
            }
        }
    }
}
