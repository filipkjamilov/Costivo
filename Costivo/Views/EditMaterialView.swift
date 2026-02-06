import SwiftUI
import SwiftData

struct EditMaterialView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var material: Material
    
    @State private var priceText: String
    
    init(material: Material) {
        self.material = material
        _priceText = State(initialValue: String(format: "%.2f", material.pricePerUnit))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Material Details") {
                    TextField("Name", text: $material.name)
                    
                    TextField("Price per Unit", text: $priceText)
                        .keyboardType(.decimalPad)
                        .onChange(of: priceText) { _, newValue in
                            if let price = Double(newValue) {
                                material.pricePerUnit = price
                            }
                        }
                }
                
                Section("Unit Type") {
                    Picker("Unit Type", selection: $material.unitType) {
                        ForEach(UnitType.allCases, id: \.self) { unitType in
                            Text(unitType.rawValue).tag(unitType)
                        }
                    }
                    .onChange(of: material.unitType) { _, newValue in
                        if !newValue.availableUnits.contains(material.specificUnit) {
                            material.specificUnit = newValue.availableUnits.first ?? ""
                        }
                    }
                    
                    Picker("Specific Unit", selection: $material.specificUnit) {
                        ForEach(material.unitType.availableUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
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
