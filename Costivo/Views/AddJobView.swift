import SwiftUI
import SwiftData

struct AddJobView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var materials: [Material]
    @Query private var laborRates: [LaborRate]
    @Query private var settings: [AppSettings]
    
    @State private var clientName = ""
    @State private var selectedMaterials: [SelectedMaterial] = []
    @State private var selectedLabor: [SelectedLabor] = []
    @State private var showingMaterialPicker = false
    @State private var showingLaborPicker = false
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client Name", text: $clientName)
                }
                
                Section {
                    ForEach($selectedMaterials) { $material in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(material.material.name)
                                    .font(.subheadline)
                                Text("\(String(format: "%.2f", material.material.pricePerUnit)) / \(Unit.localizedUnit(material.material.unit))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            TextField("Qty", value: $material.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            
                            Text(Unit.localizedUnit(material.material.unit))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        selectedMaterials.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        showingMaterialPicker = true
                    } label: {
                        Label("Add Material", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Materials")
                }
                
                Section {
                    ForEach($selectedLabor) { $labor in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(labor.laborRate.name)
                                    .font(.subheadline)
                                Text("\(labor.laborRate.price, specifier: "%.2f") / \(labor.unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            TextField("Qty", value: $labor.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            
                            Text(labor.unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        selectedLabor.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        showingLaborPicker = true
                    } label: {
                        Label("Add Labor", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Labor")
                }
                
                Section {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("\(currency)\(totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("New Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJob()
                    }
                    .disabled(clientName.isEmpty)
                }
            }
            .sheet(isPresented: $showingMaterialPicker) {
                MaterialPickerView(materials: materials) { material in
                    selectedMaterials.append(SelectedMaterial(material: material, quantity: 1.0))
                }
            }
            .sheet(isPresented: $showingLaborPicker) {
                LaborPickerView(laborRates: laborRates) { labor in
                    selectedLabor.append(SelectedLabor(laborRate: labor, quantity: 1.0))
                }
            }
        }
    }
    
    private var totalCost: Double {
        let materialsTotal = selectedMaterials.reduce(0) { total, item in
            total + (item.material.pricePerUnit * item.quantity)
        }
        let laborTotal = selectedLabor.reduce(0) { total, item in
            total + (item.laborRate.price * item.quantity)
        }
        return materialsTotal + laborTotal
    }
    
    private func saveJob() {
        let job = Job(clientName: clientName)
        
        for selected in selectedMaterials {
            let jobMaterial = JobMaterial(
                materialName: selected.material.name,
                pricePerUnit: selected.material.pricePerUnit,
                unit: selected.material.unit,
                quantity: selected.quantity
            )
            job.materialEntries.append(jobMaterial)
            modelContext.insert(jobMaterial)
        }
        
        for selected in selectedLabor {
            let unit: String
            switch selected.laborRate.pricingModel {
            case .hourly:
                unit = "hour"
            case .fixed:
                unit = "job"
            case .perUnit:
                unit = selected.laborRate.unit ?? "unit"
            }
            
            let jobLabor = JobLabor(
                laborName: selected.laborRate.name,
                pricePerUnit: selected.laborRate.price,
                unit: unit,
                quantity: selected.quantity
            )
            job.laborEntries.append(jobLabor)
            modelContext.insert(jobLabor)
        }
        
        modelContext.insert(job)
        dismiss()
    }
}

struct SelectedMaterial: Identifiable {
    let id = UUID()
    let material: Material
    var quantity: Double
}

struct SelectedLabor: Identifiable {
    let id = UUID()
    let laborRate: LaborRate
    var quantity: Double
    
    var unit: String {
        switch laborRate.pricingModel {
        case .hourly:
            return "hour"
        case .fixed:
            return "job"
        case .perUnit:
            return laborRate.unit ?? "unit"
        }
    }
}

#Preview {
    AddJobView()
        .modelContainer(for: [Job.self, Material.self, LaborRate.self])
}
