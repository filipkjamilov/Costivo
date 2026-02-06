import SwiftUI
import SwiftData

struct AddMaterialView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    
    @State private var name = ""
    @State private var pricePerUnit = ""
    @State private var selectedUnit = "piece"
    @State private var showingPredefined = false
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingPredefined = true
                    } label: {
                        Label(L(.chooseFromCommon), systemImage: "list.bullet")
                    }
                } header: {
                    Text(L(.quickAdd))
                } footer: {
                    Text(L(.selectFromCommonMaterials))
                }
                
                Section(L(.materialDetails)) {
                    TextField(L(.materialNamePlaceholder), text: $name)
                    
                    HStack {
                        Text(currency)
                            .foregroundStyle(.secondary)
                        TextField(L(.pricePerUnit), text: $pricePerUnit)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(L(.unit)) {
                    Picker(L(.unit), selection: $selectedUnit) {
                        ForEach(Unit.allUnits, id: \.self) { unit in
                            Text(Unit.localizedUnitKey(unit)).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle(L(.addMaterialButton))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.add)) {
                        saveMaterial()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingPredefined) {
                PredefinedMaterialsView { predefined in
                    name = predefined.localizedName()
                    selectedUnit = predefined.unit
                    if let suggested = predefined.suggestedPrice {
                        pricePerUnit = String(format: "%.2f", suggested)
                    }
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
            unit: selectedUnit
        )
        
        modelContext.insert(material)
        dismiss()
    }
}

#Preview("English") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, AppSettings.self,
        configurations: config
    )
    
    return AddMaterialView()
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Macedonian") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, AppSettings.self,
        configurations: config
    )
    
    return AddMaterialView()
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "mk"))
}
