import SwiftUI
import SwiftData
import UIKit
import RevenueCatUI

struct SettingsView: View {
    @Query private var settings: [AppSettings]
    @Query(sort: \LaborRate.name) private var laborRates: [LaborRate]
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var showingProfile = false
    @State private var showingCurrencyPicker = false
    @State private var showingProfessionPicker = false
    @State private var showingPaywall = false
    @State private var showingCustomerCenter = false

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
                    HStack {
                        Text(L(.subscription))
                        Spacer()
                        Text(subscriptionManager.effectiveStatus.displayName)
                            .foregroundStyle(.secondary)
                    }

                    if case .trial(let expiresAt) = subscriptionManager.effectiveStatus {
                        HStack {
                            Text(L(.trialExpiresOn))
                            Spacer()
                            Text(expiresAt, style: .date)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if case .subscribed = subscriptionManager.effectiveStatus {
                        Button {
                            showingCustomerCenter = true
                        } label: {
                            Text(L(.manageSubscription))
                        }
                    }

                    if case .expired = subscriptionManager.effectiveStatus {
                        Button {
                            showingPaywall = true
                        } label: {
                            Text(L(.subscribe))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.yellowBase)
                        }
                    }
                } header: {
                    Text(L(.subscriptionSection))
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
            .sheet(isPresented: $showingPaywall) {
                PaywallView(isDismissible: true)
            }
            .sheet(isPresented: $showingCustomerCenter) {
                CustomerCenterView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self)
        .environment(SubscriptionManager())
}
