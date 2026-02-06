import SwiftUI
import SwiftData

struct EditLaborRateView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    @Bindable var laborRate: LaborRate
    
    @State private var priceText: String
    @State private var unit: String
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    init(laborRate: LaborRate) {
        self.laborRate = laborRate
        _priceText = State(initialValue: String(format: "%.2f", laborRate.price))
        _unit = State(initialValue: laborRate.unit ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.laborDetails)) {
                    TextField(L(.name), text: $laborRate.name)
                    
                    HStack {
                        Text(currency)
                            .foregroundStyle(.secondary)
                        TextField(L(.price), text: $priceText)
                            .keyboardType(.decimalPad)
                            .onChange(of: priceText) { _, newValue in
                                if let price = Double(newValue) {
                                    laborRate.price = price
                                }
                            }
                    }
                }
                
                Section(L(.pricingModel)) {
                    Picker(L(.model), selection: $laborRate.pricingModel) {
                        ForEach(PricingModel.allCases, id: \.self) { model in
                            Text(model.localizedName).tag(model)
                        }
                    }
                    
                    if laborRate.pricingModel.requiresUnit {
                        TextField(L(.unitPlaceholder), text: $unit)
                            .onChange(of: unit) { _, newValue in
                                laborRate.unit = newValue
                            }
                    }
                }
            }
            .navigationTitle(L(.editLaborRate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.done)) {
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard !laborRate.name.isEmpty, Double(priceText) != nil else { return false }
        if laborRate.pricingModel.requiresUnit {
            return !unit.isEmpty
        }
        return true
    }
}
