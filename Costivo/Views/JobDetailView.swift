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
    @State private var showingShareSheet = false
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    private var shareText: String {
        JobShareService.formatJobForSharing(job: job, currency: currency)
    }
    
    private var shareTitle: String {
        L(.costEstimateWithClient, job.clientName)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L(.client)) {
                    TextField(L(.clientName), text: $job.clientName)
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
                            
                            TextField(L(.quantity), value: $material.quantity, format: .number)
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
                        Label(L(.addMaterialButton), systemImage: "plus.circle")
                    }
                } header: {
                    Text(L(.materialsSection))
                } footer: {
                    let materialsTotal = job.materialEntries.reduce(0) { $0 + $1.totalPrice }
                    Text("\(L(.materialsTotal)) \(currency)\(materialsTotal, specifier: "%.2f")")
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
                            
                            TextField(L(.quantity), value: $labor.quantity, format: .number)
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
                        Label(L(.addLabor), systemImage: "plus.circle")
                    }
                } header: {
                    Text(L(.laborSection))
                } footer: {
                    let laborTotal = job.laborEntries.reduce(0) { $0 + $1.totalPrice }
                    Text("\(L(.laborTotal)) \(currency)\(laborTotal, specifier: "%.2f")")
                }
                
                Section {
                    HStack {
                        Text(L(.totalCostSection))
                            .font(.headline)
                        Spacer()
                        Text("\(currency)\(job.totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle(L(.jobDetails))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label(L(.share), systemImage: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.done)) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [shareText], subject: shareTitle)
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
                        unit = L(.hour)
                    case .fixed:
                        unit = L(.job)
                    case .perUnit:
                        unit = labor.unit ?? L(.unitLabel)
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
