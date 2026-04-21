import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Query private var settings: [AppSettings]
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]

    @State private var showingProfile = false
    @State private var showingCurrencyPicker = false
    @State private var showingProfessionPicker = false

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
                    Button {
                        showingProfile = true
                    } label: {
                        HStack(spacing: 14) {
                            ProfileAvatar(name: settings.handymanName ?? "", size: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(settings.handymanName ?? L(.profileNotSet))
                                    .font(.headline)
                                    .foregroundStyle(settings.handymanName != nil ? .primary : .secondary)

                                if let company = settings.businessName {
                                    Text(company)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .tint(.primary)

                Section {
                    Button {
                        showingCurrencyPicker = true
                    } label: {
                        HStack {
                            Text(L(.currency))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(settings.currency.label)
                                .foregroundStyle(.secondary)
                        }
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
                .tint(.primary)

                Section {
                    NavigationLink {
                        LaborRatesView()
                    } label: {
                        HStack {
                            Text(L(.laborRates))
                            Spacer()
                            Text("\(laborRates.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
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
            .sheet(isPresented: $showingProfile) {
                BusinessProfileView()
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerView(current: settings.currency.rawValue)
            }
            .sheet(isPresented: $showingProfessionPicker) {
                ProfessionPickerView(current: settings.handymanType)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self)
}
