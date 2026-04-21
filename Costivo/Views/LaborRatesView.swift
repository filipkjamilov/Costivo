import SwiftUI
import SwiftData

struct LaborRatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]
    @State private var showingAddLabor = false
    @State private var editingLabor: LaborRate?
    
    var body: some View {
        List {
            ForEach(laborRates) { labor in
                LaborRateRow(laborRate: labor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingLabor = labor
                    }
            }
            .onDelete(perform: deleteLaborRates)
        }
        .appBackground()
        .navigationTitle(L(.laborRates))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddLabor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddLabor) {
            AddLaborRateView()
        }
        .sheet(item: $editingLabor) { labor in
            EditLaborRateView(laborRate: labor)
        }
        .overlay {
            if laborRates.isEmpty {
                ContentUnavailableView(
                    L(.noLaborRates),
                    systemImage: "wrench.and.screwdriver",
                    description: Text(L(.addFirstLaborRate))
                )
            }
        }
    }
    
    private func deleteLaborRates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(laborRates[index])
        }
    }
}

struct LaborRateRow: View {
    let laborRate: LaborRate
    @Query private var settings: [AppSettings]
    
    private var currency: String {
        settings.currency.symbol
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .foregroundStyle(Color.orangeBase)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(laborRate.name)
                    .font(.headline)
                Text(subtitleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(currency)\(laborRate.price, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var subtitleText: String {
        switch laborRate.pricingModel {
        case .hourly:
            return laborRate.pricingModel.rawValue
        case .fixed:
            return laborRate.pricingModel.rawValue
        case .perUnit:
            if let unit = laborRate.unit, !unit.isEmpty {
                return "\(laborRate.pricingModel.rawValue) · \(unit)"
            }
            return laborRate.pricingModel.rawValue
        }
    }
}

#Preview {
    LaborRatesView()
        .modelContainer(for: [LaborRate.self, AppSettings.self])
}
