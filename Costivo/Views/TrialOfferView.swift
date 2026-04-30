import SwiftUI

struct TrialOfferView: View {
    var onComplete: () -> Void

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 0) {
                AnimationView(.paymentHero, loops: true)
                    .frame(height: 200)
                    .padding(.top, 40)
                    .padding(.horizontal, 40)
                    .allowsHitTesting(false)

                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L(.trialOfferTitle))
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.primary)

                        Text(L(.trialOfferSubtitle))
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow(icon: "doc.text.fill",           color: .yellowBase, text: L(.trialOfferFeature1))
                        featureRow(icon: "square.stack.3d.up.fill", color: .blueBold,   text: L(.trialOfferFeature2))
                        featureRow(icon: "calendar.badge.checkmark",color: .greenBold,  text: L(.trialOfferFeature3))
                        featureRow(icon: "arrow.up.doc.fill",       color: .orangeBase, text: L(.trialOfferFeature4))
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        subscriptionManager.startTrial()
                        onComplete()
                    } label: {
                        Text(L(.startFreeTrial))
                            .font(.headline)
                            .foregroundStyle(Color.greyBase)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.yellowBase, in: RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        showPaywall = true
                    } label: {
                        Text(L(.trialOfferSeePricing))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(L(.trialOfferDisclaimer))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 4) {
                        Link(L(.termsOfUse), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stddla/")!)
                        Text("·").foregroundStyle(.tertiary)
                        Link(L(.privacyPolicy), destination: URL(string: "https://filipkjamilov.com/CostivoWeb/privacy-policy.html")!)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 44)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isDismissible: true)
        }
        .onChange(of: subscriptionManager.isActiveSubscription) { _, isActive in
            if isActive { onComplete() }
        }
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28, alignment: .center)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

#Preview {
    TrialOfferView(onComplete: {})
        .environment(SubscriptionManager())
}
