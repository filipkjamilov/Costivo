import SwiftUI
import SwiftData

struct EditMaterialView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    @Bindable var material: Material
    
    @State private var priceText: String
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    init(material: Material) {
        self.material = material
        _priceText = State(initialValue: String(format: "%.2f", material.pricePerUnit))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Material Details") {
                    TextField("Name", text: $material.name)
                    
                    HStack {
                        Text(currency)
                            .foregroundStyle(.secondary)
                        TextField("Price per Unit", text: $priceText)
                            .keyboardType(.decimalPad)
                            .onChange(of: priceText) { _, newValue in
                                if let price = Double(newValue) {
                                    material.pricePerUnit = price
                                }
                            }
                    }
                }
                
                Section("Unit") {
                    Picker("Unit", selection: $material.unit) {
                        ForEach(Unit.allUnits, id: \.self) { unit in
                            Text(Unit.localizedUnitKey(unit)).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("Edit Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(material.name.isEmpty || Double(priceText) == nil)
                }
            }
        }
    }
}
