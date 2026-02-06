import SwiftUI
import SwiftData

struct LaborRatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]
    @State private var showingAddLabor = false
    @State private var editingLabor: LaborRate?
    
    var body: some View {
        NavigationStack {
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
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(laborRate.name)
                    .font(.headline)
                Text(laborRate.pricingModel.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(formattedPrice)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var formattedPrice: String {
        let priceStr = "\(currency)\(String(format: "%.2f", laborRate.price))"
        
        switch laborRate.pricingModel {
        case .hourly:
            return "\(priceStr) / hour"
        case .fixed:
            return "\(priceStr) / job"
        case .perUnit:
            return "\(priceStr) / \(laborRate.unit ?? "unit")"
        }
    }
}

#Preview {
    LaborRatesView()
        .modelContainer(for: [LaborRate.self, AppSettings.self])
}
