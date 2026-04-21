import SwiftUI
import SwiftData

struct AddJobView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var materials: [Material]
    @Query private var laborRates: [LaborRate]
    @Query private var settings: [AppSettings]
    
    @State private var clientName = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var selectedMaterials: [SelectedMaterial] = []
    @State private var selectedLabor: [SelectedLabor] = []
    @State private var showingMaterialPicker = false
    @State private var showingLaborPicker = false
    
    private var currency: String {
        settings.currency.symbol
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.client)) {
                    TextField(L(.clientName), text: $clientName)

                    Toggle(L(.dueDateOptional), isOn: $hasDueDate.animation())

                    if hasDueDate {
                        DatePicker(L(.dueDate), selection: $dueDate, displayedComponents: .date)
                    }
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
                            
                            TextField(L(.quantity), value: $material.quantity, format: .number)
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
                        Label(L(.addMaterialButton), systemImage: "plus.circle")
                    }
                } header: {
                    Text(L(.materialsSection))
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
                            
                            TextField(L(.quantity), value: $labor.quantity, format: .number)
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
                        Label(L(.addLabor), systemImage: "plus.circle")
                    }
                } header: {
                    Text(L(.laborSection))
                }
                
                Section {
                    HStack {
                        Text(L(.total))
                            .font(.headline)
                        Spacer()
                        Text("\(currency)\(totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .appBackground()
            .navigationTitle(L(.newJob))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.save)) {
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
        let job = Job(
            clientName: clientName,
            dueDate: hasDueDate ? dueDate : nil,
            status: hasDueDate ? .scheduled : .draft
        )
        
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
                unit = L(.hour)
            case .fixed:
                unit = L(.job)
            case .perUnit:
                unit = selected.laborRate.unit ?? L(.unitLabel)
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
            return L(.hour)
        case .fixed:
            return L(.job)
        case .perUnit:
            return laborRate.unit ?? L(.unitLabel)
        }
    }
}

#Preview {
    AddJobView()
        .modelContainer(for: [Job.self, Material.self, LaborRate.self])
}
