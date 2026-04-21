import SwiftUI
import SwiftData

struct AddLaborRateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    
    @State private var name = ""
    @State private var priceText = ""
    @State private var selectedPricingModel: PricingModel = .hourly
    @State private var unit = ""
    
    private var currency: String {
        settings.currency.symbol
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.laborDetails)) {
                    TextField(L(.laborNamePlaceholder), text: $name)
                    
                    HStack {
                        Text(currency)
                            .foregroundStyle(.secondary)
                        TextField(L(.price), text: $priceText)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(L(.pricingModel)) {
                    Picker(L(.model), selection: $selectedPricingModel) {
                        ForEach(PricingModel.allCases, id: \.self) { model in
                            Text(model.localizedName).tag(model)
                        }
                    }
                    
                    if selectedPricingModel.requiresUnit {
                        TextField(L(.unitPlaceholder), text: $unit)
                    }
                }
            }
            .appBackground()
            .navigationTitle(L(.addLaborRate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.add)) {
                        saveLaborRate()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard !name.isEmpty, Double(priceText) != nil else { return false }
        if selectedPricingModel.requiresUnit {
            return !unit.isEmpty
        }
        return true
    }
    
    private func saveLaborRate() {
        guard let price = Double(priceText) else { return }
        
        let laborRate = LaborRate(
            name: name,
            price: price,
            pricingModel: selectedPricingModel,
            unit: selectedPricingModel.requiresUnit ? unit : nil
        )
        
        modelContext.insert(laborRate)
        dismiss()
    }
}

#Preview {
    AddLaborRateView()
        .modelContainer(for: LaborRate.self)
}
