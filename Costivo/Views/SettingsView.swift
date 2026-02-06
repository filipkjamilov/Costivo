import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]
    
    @State private var selectedCurrency: String = "€"
    @State private var showingAddLabor = false
    @State private var editingLabor: LaborRate?
    
    private let availableCurrencies = ["€", "$", "£", "¥", "CHF", "SEK", "NOK", "DKK"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .onChange(of: selectedCurrency) { _, _ in
                        saveSettings()
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Select your preferred currency for displaying prices")
                }
                
                Section {
                    ForEach(laborRates) { labor in
                        Button {
                            editingLabor = labor
                        } label: {
                            LaborRateRow(laborRate: labor)
                        }
                    }
                    .onDelete(perform: deleteLaborRates)
                    
                    Button {
                        showingAddLabor = true
                    } label: {
                        Label("Add Labor Rate", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Labor Rates")
                } footer: {
                    Text("Manage your labor pricing for estimates")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let existingSettings = settings.first {
                    selectedCurrency = existingSettings.preferredCurrency
                }
            }
            .sheet(isPresented: $showingAddLabor) {
                AddLaborRateView()
            }
            .sheet(item: $editingLabor) { labor in
                EditLaborRateView(laborRate: labor)
            }
        }
    }
    
    private func saveSettings() {
        if let existingSettings = settings.first {
            existingSettings.preferredCurrency = selectedCurrency
        } else {
            let newSettings = AppSettings(preferredCurrency: selectedCurrency)
            modelContext.insert(newSettings)
        }
    }
    
    private func deleteLaborRates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(laborRates[index])
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self)
}
