import SwiftUI
import SwiftData

struct AddLaborRateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var priceText = ""
    @State private var selectedPricingModel: PricingModel = .hourly
    @State private var unit = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Labor Details") {
                    TextField("Name (e.g., Installation, Painting)", text: $name)
                    
                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Pricing Model") {
                    Picker("Model", selection: $selectedPricingModel) {
                        ForEach(PricingModel.allCases, id: \.self) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    
                    if selectedPricingModel.requiresUnit {
                        TextField("Unit (e.g., m², piece)", text: $unit)
                    }
                }
            }
            .navigationTitle("Add Labor Rate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
