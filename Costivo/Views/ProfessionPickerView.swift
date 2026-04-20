import SwiftUI
import SwiftData

struct ProfessionPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]

    @State private var selected: HandymanType

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(current: HandymanType = .construction) {
        _selected = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(L(.chooseProfession))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                Text(L(.professionDescription))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Profession grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HandymanType.allCases, id: \.self) { type in
                        ProfessionCard(
                            type: type,
                            isSelected: selected == type
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = type
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // Live tab bar preview
                TabBarPreview(handymanType: selected)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
            .appBackground()
            .navigationTitle(L(.profession))
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

    private func save() {
        if let existingSettings = settings.first {
            existingSettings.handymanType = selected
        } else {
            let newSettings = AppSettings(handymanType: selected)
            modelContext.insert(newSettings)
        }
    }
}

// MARK: - Profession Card

struct ProfessionCard: View {
    let type: HandymanType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: type.jobsIcon)
                .font(.system(size: 28))
                .foregroundStyle(isSelected ? .white : .primary)

            Text(type.localizedName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Tab Bar Preview

struct TabBarPreview: View {
    let handymanType: HandymanType

    var body: some View {
        VStack(spacing: 8) {
            Text(L(.preview))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack {
                TabBarItem(icon: handymanType.jobsIcon, label: L(.jobs), isActive: true)
                TabBarItem(icon: handymanType.materialsIcon, label: L(.materialsTitle), isActive: false)
                TabBarItem(icon: handymanType.settingsIcon, label: L(.settings), isActive: false)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
            )
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(label)
                .font(.caption2)
        }
        .foregroundStyle(isActive ? Color.accentColor : .secondary)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )

    return ProfessionPickerView()
        .modelContainer(container)
}
