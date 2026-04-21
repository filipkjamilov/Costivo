import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("hasSetProfile") private var hasSetProfile = false
    @AppStorage("hasPickedProfession") private var hasPickedProfession = false
    @AppStorage("hasPickedCurrency") private var hasPickedCurrency = false

    var onComplete: () -> Void

    var body: some View {
        if !hasSeenTutorial {
            TutorialView {
                withAnimation {
                    hasSeenTutorial = true
                }
            }
        } else if !hasSetProfile {
            BusinessProfileView {
                withAnimation {
                    hasSetProfile = true
                }
            }
        } else if !hasPickedProfession {
            ProfessionPickerView {
                withAnimation {
                    hasPickedProfession = true
                }
            }
        } else if !hasPickedCurrency {
            CurrencyPickerView {
                withAnimation {
                    hasPickedCurrency = true
                    onComplete()
                }
            }
        }
    }

    var isComplete: Bool {
        hasSeenTutorial && hasSetProfile && hasPickedProfession && hasPickedCurrency
    }
}
