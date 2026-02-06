import SwiftUI
import SwiftData

struct AddMaterialView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var pricePerUnit = ""
    @State private var selectedUnitType: UnitType = .piece
    @State private var selectedSpecificUnit = "piece"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Material Details") {
                    TextField("Name (e.g., Concrete, Tiles)", text: $name)
                    
                    TextField("Price per Unit", text: $pricePerUnit)
                        .keyboardType(.decimalPad)
                }
                
                Section("Unit Type") {
                    Picker("Unit Type", selection: $selectedUnitType) {
                        ForEach(UnitType.allCases, id: \.self) { unitType in
                            Text(unitType.rawValue).tag(unitType)
                        }
                    }
                    .onChange(of: selectedUnitType) { _, newValue in
                        selectedSpecificUnit = newValue.availableUnits.first ?? ""
                    }
                    
                    Picker("Specific Unit", selection: $selectedSpecificUnit) {
                        ForEach(selectedUnitType.availableUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("Add Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveMaterial()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && Double(pricePerUnit) != nil
    }
    
    private func saveMaterial() {
        guard let price = Double(pricePerUnit) else { return }
        
        let material = Material(
            name: name,
            pricePerUnit: price,
            unitType: selectedUnitType,
            specificUnit: selectedSpecificUnit
        )
        
        modelContext.insert(material)
        dismiss()
    }
}

#Preview {
    AddMaterialView()
        .modelContainer(for: Material.self)
}
