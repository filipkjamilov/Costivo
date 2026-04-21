import SwiftUI
import SwiftData

struct BusinessProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]

    @State private var name: String
    @State private var company: String

    var onComplete: (() -> Void)?

    static let nameMaxLength = 40
    static let companyMaxLength = 50

    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        _name = State(initialValue: "")
        _company = State(initialValue: "")
    }

    var body: some View {
        Group {
            if onComplete != nil {
                content
            } else {
                NavigationStack {
                    content
                        .navigationTitle(L(.profileTitle))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(L(.done)) {
                                    save()
                                    dismiss()
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            name = settings.handymanName ?? ""
            company = settings.businessName ?? ""
        }
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

            ProfileAvatar(name: name, size: 80)

            Text(L(.profileTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(L(.profileDescription))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                TextField(L(.handymanNamePlaceholder), text: $name)
                    .textContentType(.name)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    .onChange(of: name) { _, newValue in
                        if newValue.count > Self.nameMaxLength {
                            name = String(newValue.prefix(Self.nameMaxLength))
                        }
                    }

                TextField(L(.companyNamePlaceholder), text: $company)
                    .textContentType(.organizationName)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    .onChange(of: company) { _, newValue in
                        if newValue.count > Self.companyMaxLength {
                            company = String(newValue.prefix(Self.companyMaxLength))
                        }
                    }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()

            if let onComplete {
                Button {
                    save()
                    onComplete()
                } label: {
                    Text(L(.continueButton))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.yellowBase, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            } else {
                Spacer()
                    .frame(height: 8)
            }
        }
        .appBackground()
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCompany = company.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = settings.first {
            existing.handymanName = trimmedName.isEmpty ? nil : trimmedName
            existing.businessName = trimmedCompany.isEmpty ? nil : trimmedCompany
        } else {
            let newSettings = AppSettings()
            newSettings.handymanName = trimmedName.isEmpty ? nil : trimmedName
            newSettings.businessName = trimmedCompany.isEmpty ? nil : trimmedCompany
            modelContext.insert(newSettings)
        }
    }
}

// MARK: - Profile Avatar

struct ProfileAvatar: View {
    let name: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.yellowBase, .orangeBase],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Text(initials)
                .font(.system(size: size * 0.35, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let parts = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .filter { !$0.isEmpty }

        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else if let first = parts.first, !first.isEmpty {
            return String(first.prefix(1)).uppercased()
        } else {
            return "?"
        }
    }
}

// MARK: - Preview

#Preview("Settings") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )

    return BusinessProfileView()
        .modelContainer(container)
}

#Preview("Onboarding") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )

    return BusinessProfileView(onComplete: {})
        .modelContainer(container)
}
