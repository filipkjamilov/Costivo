import SwiftUI
import SwiftData

struct DebugConsoleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @Query private var materials: [Material]
    @Query private var laborRates: [LaborRate]
    @Query private var jobs: [Job]

    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("hasSetProfile") private var hasSetProfile = false
    @AppStorage("hasPickedProfession") private var hasPickedProfession = false
    @AppStorage("hasPickedCurrency") private var hasPickedCurrency = false
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @AppStorage("walkthroughMigrationDone") private var walkthroughMigrationDone = false

    @State private var toastMessage: String?

    var body: some View {
        NavigationStack {
            List {
                statusSection
                overridesSection
                trialSection
                rcSection
                onboardingSection
                dataSection
            }
            .navigationTitle("Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .overlay(alignment: .bottom) {
                if let msg = toastMessage {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.8), in: Capsule())
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        Section("Subscription Status") {
            HStack {
                Text("Status")
                Spacer()
                Text(statusLabel)
                    .font(.subheadline.bold())
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15), in: Capsule())
            }
            if subscriptionManager.debugOverride != nil {
                infoRow("Mode", value: "⚠︎ Override active", valueColor: Color.orangeBase)
            }
            if let expiry = subscriptionManager.trialExpiryDate {
                infoRow("Trial expires", value: expiry.formatted(date: .abbreviated, time: .omitted))
                infoRow("Days remaining", value: "\(daysUntil(expiry))")
            }
            infoRow(
                "Entitlement",
                value: subscriptionManager.isEntitlementActive ? "Active" : "Inactive",
                valueColor: subscriptionManager.isEntitlementActive ? Color.greenBase : Color.redBase
            )
            infoRow("RC User ID", value: subscriptionManager.rcUserID)
            infoRow("Version", value: "\(appVersion) (\(buildNumber))")
            infoRow("Bundle ID", value: Bundle.main.bundleIdentifier ?? "—")
        }
    }

    // MARK: - Overrides

    private var overridesSection: some View {
        Section {
            overrideButton("Subscribed — Yearly (renewing)") {
                let expiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                subscriptionManager.debugOverride = .subscribed(expiresAt: expiry, willRenew: true)
            }
            overrideButton("Subscribed — Lifetime") {
                subscriptionManager.debugOverride = .subscribed(expiresAt: .distantFuture, willRenew: false)
            }
            overrideButton("Trial — 30 days remaining") {
                subscriptionManager.debugOverride = .trial(expiresAt: Date().addingTimeInterval(30 * 86400))
            }
            overrideButton("Trial — 7 days remaining") {
                subscriptionManager.debugOverride = .trial(expiresAt: Date().addingTimeInterval(7 * 86400))
            }
            overrideButton("Trial — 1 day (expiring soon)") {
                subscriptionManager.debugOverride = .trial(expiresAt: Date().addingTimeInterval(86400))
            }
            Button("Expired") {
                subscriptionManager.debugOverride = .expired
                toast("Override: Expired")
            }
            .foregroundStyle(Color.redBase)
            Button("Revoked") {
                subscriptionManager.debugOverride = .revoked
                toast("Override: Revoked")
            }
            .foregroundStyle(Color.redBase)
            Button("Clear Override") {
                subscriptionManager.debugOverride = nil
                toast("Override cleared")
            }
            .foregroundStyle(Color.orangeBase)
        } header: {
            Text("Status Overrides")
        } footer: {
            Text("Overrides are in-memory only. App restart clears them.")
        }
    }

    // MARK: - Trial

    private var trialSection: some View {
        Section("Trial Controls") {
            Button("Start fresh 30-day trial (from now)") {
                subscriptionManager.resetTrialDate()
                subscriptionManager.startTrial()
                subscriptionManager.debugOverride = nil
                toast("Trial started from today")
            }
            Button("Set trial to expire in 7 days") {
                setTrialExpiry(daysFromNow: 7)
                toast("Trial expiry: 7 days")
            }
            Button("Set trial to expire in 1 day") {
                setTrialExpiry(daysFromNow: 1)
                toast("Trial expiry: 1 day")
            }
            Button("Set trial as expired (30 days ago)", role: .destructive) {
                setTrialExpiry(daysFromNow: -30)
                toast("Trial set to expired")
            }
            Button("Reset trial completely", role: .destructive) {
                subscriptionManager.resetTrialDate()
                subscriptionManager.debugOverride = nil
                Task { await subscriptionManager.checkEntitlements() }
                toast("Trial reset — no trial started")
            }
        }
    }

    // MARK: - RevenueCat

    private var rcSection: some View {
        Section("RevenueCat") {
            Button("Refresh Customer Info") {
                Task {
                    await subscriptionManager.checkEntitlements()
                    toast("Customer info refreshed")
                }
            }
        }
    }

    // MARK: - Onboarding

    private var onboardingSection: some View {
        Section {
            onboardingRow("Tutorial", isComplete: hasSeenTutorial) {
                hasSeenTutorial = false
                toast("Tutorial reset")
            }
            onboardingRow("Profile", isComplete: hasSetProfile) {
                hasSetProfile = false
                toast("Profile reset")
            }
            onboardingRow("Profession", isComplete: hasPickedProfession) {
                hasPickedProfession = false
                toast("Profession reset")
            }
            onboardingRow("Currency", isComplete: hasPickedCurrency) {
                hasPickedCurrency = false
                toast("Currency reset")
            }
            onboardingRow("Walkthrough", isComplete: hasSeenWalkthrough) {
                hasSeenWalkthrough = false
                walkthroughMigrationDone = false
                toast("Walkthrough reset")
            }
            Button("Reset All Onboarding", role: .destructive) {
                hasSeenTutorial = false
                hasSetProfile = false
                hasPickedProfession = false
                hasPickedCurrency = false
                hasSeenWalkthrough = false
                walkthroughMigrationDone = false
                toast("Onboarding reset — restart app")
            }
        } header: {
            Text("Onboarding")
        } footer: {
            Text("Tap a completed step to reset it. Restart the app to re-run from that step.")
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section {
            infoRow("Materials", value: "\(materials.count)")
            infoRow("Labor Rates", value: "\(laborRates.count)")
            infoRow("Jobs", value: "\(jobs.count)")
            Button("Populate Test Data") {
                SeedData.populate(into: modelContext)
                toast("Test data populated")
            }
            Button("Clear All Data", role: .destructive) {
                clearAllData()
                toast("All data cleared")
            }
            Button("Full Reset (UserDefaults + Data)", role: .destructive) {
                clearAllData()
                clearSettings()
                if let bundleId = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleId)
                }
                toast("Full reset — kill & relaunch")
            }
        } header: {
            Text("Data")
        }
    }

    // MARK: - View Helpers

    private func infoRow(_ label: String, value: String, valueColor: Color = .secondary) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
                .font(.subheadline)
        }
    }

    private func overrideButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(label) {
            action()
            toast("Override: \(label)")
        }
    }

    private func onboardingRow(_ label: String, isComplete: Bool, onReset: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
            Spacer()
            if isComplete {
                Button {
                    onReset()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Done")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.greenBase)
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "circle")
                    Text("Pending")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func toast(_ message: String) {
        withAnimation(.spring(duration: 0.3)) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(duration: 0.3)) { toastMessage = nil }
        }
    }

    private func setTrialExpiry(daysFromNow: Int) {
        let trialStart = Calendar.current.date(byAdding: .day, value: daysFromNow - 30, to: Date())!
        subscriptionManager.setTrialStartDate(trialStart)
        subscriptionManager.debugOverride = nil
    }

    private func daysUntil(_ date: Date) -> Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0)
    }

    private var statusLabel: String {
        switch subscriptionManager.effectiveStatus {
        case .notDetermined:             return "Not Determined"
        case .trial(let date):           return "Trial (\(daysUntil(date))d left)"
        case .subscribed(_, true):       return "Subscribed ↻"
        case .subscribed(_, false):      return "Lifetime"
        case .expired:                   return "Expired"
        case .revoked:                   return "Revoked"
        }
    }

    private var statusColor: Color {
        switch subscriptionManager.effectiveStatus {
        case .notDetermined:    return .secondary
        case .trial:            return Color.yellowBase
        case .subscribed:       return Color.greenBase
        case .expired, .revoked: return Color.redBase
        }
    }

    private var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—" }
    private var buildNumber: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—" }

    // MARK: - Data Helpers

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

    private func clearSettings() {
        let settings = (try? modelContext.fetch(FetchDescriptor<AppSettings>())) ?? []
        settings.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}
