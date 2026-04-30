import SwiftUI
import RevenueCatUI

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    var isDismissible: Bool = true

    var body: some View {
        #if DEBUG && !QA_BUILD
        DebugPaywallView(isDismissible: isDismissible)
        #else
        ZStack(alignment: .topTrailing) {
            RevenueCatUI.PaywallView()
                .onPurchaseCompleted { _ in
                    Task { await subscriptionManager.checkEntitlements() }
                    if isDismissible { dismiss() }
                }
                .onRestoreCompleted { _ in
                    Task { await subscriptionManager.checkEntitlements() }
                    if isDismissible { dismiss() }
                }
                .onPurchaseFailure { error in
                    print("RevenueCat: Purchase failed: \(error)")
                }
                .onRestoreFailure { error in
                    print("RevenueCat: Restore failed: \(error)")
                }
                .interactiveDismissDisabled(!isDismissible)

            if isDismissible {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.greyMuted, Color.greyBase.opacity(0.3))
                }
                .padding(.top, 56)
                .padding(.trailing, 20)
            }
        }
        #endif
    }
}

#if DEBUG && !QA_BUILD
private struct DebugPaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    var isDismissible: Bool

    var body: some View {
        ZStack {
            AppGradientBackground()
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Debug Paywall")
                        .font(.title2.bold())
                    Text("RC paywall unavailable with test key.\nUse overrides below to simulate purchase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 12) {
                    debugButton("Simulate Yearly Subscription", color: .greenBase) {
                        let expiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                        subscriptionManager.debugOverride = .subscribed(expiresAt: expiry, willRenew: true)
                        dismiss()
                    }
                    debugButton("Simulate Lifetime Purchase", color: .greenBase) {
                        subscriptionManager.debugOverride = .subscribed(expiresAt: .distantFuture, willRenew: false)
                        dismiss()
                    }
                    debugButton("Start Free Trial (30 days)", color: .yellowBase) {
                        subscriptionManager.startTrial()
                        subscriptionManager.debugOverride = nil
                        dismiss()
                    }
                    if isDismissible {
                        Button("Dismiss") { dismiss() }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 44)
            }
        }
    }

    private func debugButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundStyle(Color.greyBase)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
#endif

#Preview {
    PaywallView()
        .environment(SubscriptionManager())
}
