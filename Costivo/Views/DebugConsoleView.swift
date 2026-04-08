import SwiftUI
import SwiftData

struct DebugConsoleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var materials: [Material]
    @Query private var laborRates: [LaborRate]
    @Query private var jobs: [Job]

    @State private var populateMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("App Info") {
                    row("Bundle ID", value: Bundle.main.bundleIdentifier ?? "—")
                    row("Version", value: "\(appVersion) (\(buildNumber))")
                    row("Environment", value: "QA / Dev")
                }

                Section("Database") {
                    row("Materials", value: "\(materials.count)")
                    row("Labor Rates", value: "\(laborRates.count)")
                    row("Jobs", value: "\(jobs.count)")
                }

                Section("Data Tools") {
                    Button("Populate Test Data") {
                        SeedData.populate(into: modelContext)
                        populateMessage = "Test data populated."
                    }

                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                        populateMessage = "All data cleared."
                    }
                }

                if let message = populateMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func clearAllData() {
        let jobMaterials = (try? modelContext.fetch(FetchDescriptor<JobMaterial>())) ?? []
        jobMaterials.forEach { modelContext.delete($0) }

        let jobLabors = (try? modelContext.fetch(FetchDescriptor<JobLabor>())) ?? []
        jobLabors.forEach { modelContext.delete($0) }

        let fetchedJobs = (try? modelContext.fetch(FetchDescriptor<Job>())) ?? []
        fetchedJobs.forEach { modelContext.delete($0) }

        let fetchedMaterials = (try? modelContext.fetch(FetchDescriptor<Material>())) ?? []
        fetchedMaterials.forEach { modelContext.delete($0) }

        let fetchedLaborRates = (try? modelContext.fetch(FetchDescriptor<LaborRate>())) ?? []
        fetchedLaborRates.forEach { modelContext.delete($0) }

        try? modelContext.save()
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
