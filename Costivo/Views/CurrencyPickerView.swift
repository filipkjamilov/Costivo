import SwiftUI
import SwiftData

struct CurrencyPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]

    @State private var selected: Currency

    var onComplete: (() -> Void)?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(current: String = Currency.default.rawValue, onComplete: (() -> Void)? = nil) {
        _selected = State(initialValue: Currency(rawValue: current) ?? .default)
        self.onComplete = onComplete
    }

    var body: some View {
        Group {
            if onComplete != nil {
                content
            } else {
                NavigationStack {
                    content
                        .navigationTitle(L(.currency))
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
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(L(.selectPreferredCurrency))
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(L(.currencyDescription))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Currency.allCases, id: \.self) { currency in
                    CurrencyCard(
                        currency: currency,
                        isSelected: selected == currency
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = currency
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            CurrencyPreview(currency: selected)
                .padding(.horizontal, 24)

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
        if let existingSettings = settings.first {
            existingSettings.preferredCurrency = selected.rawValue
        } else {
            let newSettings = AppSettings(preferredCurrency: selected.rawValue)
            modelContext.insert(newSettings)
        }
    }
}

// MARK: - Currency Card

struct CurrencyCard: View {
    let currency: Currency
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(currency.symbol)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)

            Text(currency.label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
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

// MARK: - Currency Preview

struct CurrencyPreview: View {
    let currency: Currency

    var body: some View {
        VStack(spacing: 8) {
            Text(L(.preview))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(spacing: 4) {
                previewRow(L(.materials), amount: "1,250.00")
                previewRow(L(.labor), amount: "480.00")
                Divider()
                previewRow(L(.total), amount: "1,730.00", bold: true)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.regularMaterial)
            )
        }
    }

    private func previewRow(_ label: String, amount: String, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(bold ? .subheadline.bold() : .subheadline)
            Spacer()
            Text("\(currency.symbol) \(amount)")
                .font(bold ? .subheadline.bold() : .subheadline)
                .foregroundStyle(bold ? .primary : .secondary)
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

    return CurrencyPickerView()
        .modelContainer(container)
}

#Preview("Onboarding") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )

    return CurrencyPickerView(onComplete: {})
        .modelContainer(container)
}
