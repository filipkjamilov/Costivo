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
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .task {
                    subscriptionManager.configure()
                    subscriptionManager.listenForCustomerInfoUpdates()
                    await subscriptionManager.checkEntitlements()
                }
        }
        .modelContainer(for: [Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self]) { result in
            if case .failure(let error) = result {
                print("Failed to initialize model container: \(error)")
            }
        }
    }
}
