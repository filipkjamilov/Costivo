//
//  ContentView.swift
//  Costivo
//
//  Created by Filip Kjamilov on 06.02.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            JobsView()
                .tabItem {
                    Label("Jobs", systemImage: "doc.text")
                }
            
            MaterialsView()
                .tabItem {
                    Label("Materials", systemImage: "cube.box")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self])
}
