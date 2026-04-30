import RevenueCat
import SwiftUI

@Observable
@MainActor
final class SubscriptionManager {

    // MARK: - Constants

    static let entitlementID = "Costivo Pro"
    static let apiKey = "appl_VvvheQvFCULLTnORFHMqmdUVXCF"
    private static let trialDays = 30
    private static let trialStartKey = "subscriptionTrialStartDate"

    // MARK: - State

    private(set) var status: SubscriptionStatus = .notDetermined
    private(set) var customerInfo: CustomerInfo?

    /// Debug override — set from DebugConsoleView for QA testing
    var debugOverride: SubscriptionStatus?

    var canAccessApp: Bool {
        effectiveStatus.canAccessApp
    }

    var effectiveStatus: SubscriptionStatus {
        debugOverride ?? status
    }

    var isActiveSubscription: Bool {
        if case .subscribed = effectiveStatus { return true }
        return false
    }

    var isEntitlementActive: Bool {
        customerInfo?.entitlements[Self.entitlementID]?.isActive == true
    }

    var rcUserID: String {
        Purchases.shared.appUserID
    }

    // MARK: - Trial

    private var trialStartDate: Date? {
        get { UserDefaults.standard.object(forKey: Self.trialStartKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Self.trialStartKey) }
    }

    var trialExpiryDate: Date? {
        guard let start = trialStartDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: Self.trialDays, to: start)
    }

    func startTrial() {
        guard trialStartDate == nil else { return }
        trialStartDate = Date()
        if case .notDetermined = status {
            status = .trial(expiresAt: trialExpiryDate!)
        }
    }

    func resetTrialDate() {
        UserDefaults.standard.removeObject(forKey: Self.trialStartKey)
    }

    func setTrialStartDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: Self.trialStartKey)
        checkLocalTrial()
    }

    // MARK: - Configuration

    func configure() {
        #if DEBUG || QA_BUILD
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif
        Purchases.configure(withAPIKey: Self.apiKey)
    }

    // MARK: - Entitlement Check

    func checkEntitlements() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            updateStatus(from: info)
        } catch {
            print("RevenueCat: Failed to fetch customer info: \(error)")
            // Fall back to local trial check
            checkLocalTrial()
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async -> Bool {
        do {
            let info = try await Purchases.shared.restorePurchases()
            customerInfo = info
            updateStatus(from: info)
            return info.entitlements[Self.entitlementID]?.isActive == true
        } catch {
            print("RevenueCat: Restore failed: \(error)")
            return false
        }
    }

    // MARK: - Status Update

    private func updateStatus(from info: CustomerInfo) {
        if let entitlement = info.entitlements[Self.entitlementID], entitlement.isActive {
            let expiresAt = entitlement.expirationDate ?? .distantFuture
            let willRenew = entitlement.willRenew
            status = .subscribed(expiresAt: expiresAt, willRenew: willRenew)
            #if DEBUG || QA_BUILD
            debugOverride = nil
            #endif
        } else {
            checkLocalTrial()
        }
    }

    private func checkLocalTrial() {
        if let expiry = trialExpiryDate {
            if Date() < expiry {
                status = .trial(expiresAt: expiry)
            } else {
                status = .expired
            }
        } else {
            status = .notDetermined
        }
    }

    // MARK: - Listener

    func listenForCustomerInfoUpdates() {
        Purchases.shared.delegate = RevenueCatDelegate { [weak self] info in
            Task { @MainActor in
                self?.customerInfo = info
                self?.updateStatus(from: info)
            }
        }
    }
}

// MARK: - RevenueCat Delegate

private final class RevenueCatDelegate: NSObject, PurchasesDelegate {
    let onUpdate: (CustomerInfo) -> Void

    init(onUpdate: @escaping (CustomerInfo) -> Void) {
        self.onUpdate = onUpdate
    }

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        onUpdate(customerInfo)
    }
}
