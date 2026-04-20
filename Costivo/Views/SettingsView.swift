import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]
    
    @State private var selectedCurrency: String = "MKD"
    @State private var showingProfessionPicker = false
    @State private var showingAddLabor = false
    @State private var editingLabor: LaborRate?
    
    private let availableCurrencies = ["MKD", "RSD", "€"]
    
    private var feedbackURL: URL? {
        var components = URLComponents(string: "https://docs.google.com/forms/d/e/1FAIpQLSeTvtrxQ3edPIvtVue15qLHlu14DGkBkw2gCr-0iLdhBVAq1w/viewform")
        
        components?.queryItems = [
            URLQueryItem(name: "utm_source", value: "costivo_app"),
            URLQueryItem(name: "utm_medium", value: "ios"),
            URLQueryItem(name: "utm_campaign", value: "feedback"),
            URLQueryItem(name: "utm_content", value: "iOS_\(UIDevice.current.systemVersion)_\(UIDevice.current.model)_v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
        ]
        
        return components?.url
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(L(.currency), selection: $selectedCurrency) {
                        ForEach(availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .onChange(of: selectedCurrency) { _, _ in
                        saveSettings()
                    }

                    Button {
                        showingProfessionPicker = true
                    } label: {
                        HStack {
                            Text(L(.profession))
                                .foregroundStyle(.primary)
                            Spacer()
                            Label(
                                settings.handymanType.localizedName,
                                systemImage: settings.handymanType.jobsIcon
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(L(.preferences))
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
                        Label(L(.addLaborRate), systemImage: "plus.circle")
                    }
                } header: {
                    Text(L(.laborRates))
                } footer: {
                    Text(L(.manageLaborPricing))
                }
                
                Section {
                    Button {
                        if let url = feedbackURL {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label(L(.sendFeedback), systemImage: "envelope.fill")
                    }
                } header: {
                    Text(L(.support))
                } footer: {
                    Text(L(.shareFeedbackPrompt))
                }
            }
            .appBackground()
            .navigationTitle(L(.settings))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let existingSettings = settings.first {
                    selectedCurrency = existingSettings.preferredCurrency
                }
            }
            .sheet(isPresented: $showingProfessionPicker) {
                ProfessionPickerView(current: settings.handymanType)
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
