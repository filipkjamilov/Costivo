import SwiftUI
import SwiftData

struct JobDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var job: Job
    @Query private var materials: [Material]
    @Query private var laborRates: [LaborRate]
    @Query private var settings: [AppSettings]
    
    @State private var showingMaterialPicker = false
    @State private var showingLaborPicker = false
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client Name", text: $job.clientName)
                }
                
                Section {
                    ForEach($job.materialEntries) { $material in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(material.materialName)
                                    .font(.subheadline)
                                Text("\(currency)\(material.pricePerUnit, specifier: "%.2f") / \(material.unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            TextField("Qty", value: $material.quantity, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                            
                            Text(material.unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("\(currency)\(material.totalPrice, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let material = job.materialEntries[index]
                            modelContext.delete(material)
                        }
                        job.materialEntries.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        showingMaterialPicker = true
                    } label: {
                        Label("Add Material", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Materials")
                } footer: {
                    let materialsTotal = job.materialEntries.reduce(0) { $0 + $1.totalPrice }
                    Text("Materials Total: \(currency)\(materialsTotal, specifier: "%.2f")")
                }
                
                Section {
                    ForEach($job.laborEntries) { $labor in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(labor.laborName)
                                    .font(.subheadline)
                                Text("\(currency)\(labor.pricePerUnit, specifier: "%.2f") / \(labor.unit)")
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
                            
                            Text("\(currency)\(labor.totalPrice, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let labor = job.laborEntries[index]
                            modelContext.delete(labor)
                        }
                        job.laborEntries.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        showingLaborPicker = true
                    } label: {
                        Label("Add Labor", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Labor")
                } footer: {
                    let laborTotal = job.laborEntries.reduce(0) { $0 + $1.totalPrice }
                    Text("Labor Total: \(currency)\(laborTotal, specifier: "%.2f")")
                }
                
                Section {
                    HStack {
                        Text("Total Cost")
                            .font(.headline)
                        Spacer()
                        Text("\(currency)\(job.totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMaterialPicker) {
                MaterialPickerView(materials: materials) { material in
                    let jobMaterial = JobMaterial(
                        materialName: material.name,
                        pricePerUnit: material.pricePerUnit,
                        unit: material.unit,
                        quantity: 1.0
                    )
                    job.materialEntries.append(jobMaterial)
                    modelContext.insert(jobMaterial)
                }
            }
            .sheet(isPresented: $showingLaborPicker) {
                LaborPickerView(laborRates: laborRates) { labor in
                    let unit: String
                    switch labor.pricingModel {
                    case .hourly:
                        unit = "hour"
                    case .fixed:
                        unit = "job"
                    case .perUnit:
                        unit = labor.unit ?? "unit"
                    }
                    
                    let jobLabor = JobLabor(
                        laborName: labor.name,
                        pricePerUnit: labor.price,
                        unit: unit,
                        quantity: 1.0
                    )
                    job.laborEntries.append(jobLabor)
                    modelContext.insert(jobLabor)
                }
            }
        }
    }
}
