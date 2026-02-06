import SwiftUI
import SwiftData

struct EditLaborRateView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var laborRate: LaborRate
    
    @State private var priceText: String
    @State private var unit: String
    
    init(laborRate: LaborRate) {
        self.laborRate = laborRate
        _priceText = State(initialValue: String(format: "%.2f", laborRate.price))
        _unit = State(initialValue: laborRate.unit ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Labor Details") {
                    TextField("Name", text: $laborRate.name)
                    
                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)
                        .onChange(of: priceText) { _, newValue in
                            if let price = Double(newValue) {
                                laborRate.price = price
                            }
                        }
                }
                
                Section("Pricing Model") {
                    Picker("Model", selection: $laborRate.pricingModel) {
                        ForEach(PricingModel.allCases, id: \.self) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    
                    if laborRate.pricingModel.requiresUnit {
                        TextField("Unit (e.g., m², piece)", text: $unit)
                            .onChange(of: unit) { _, newValue in
                                laborRate.unit = newValue
                            }
                    }
                }
            }
            .navigationTitle("Edit Labor Rate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
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
