import Lottie
import SwiftUI

enum AppAnimation: String {
    case checkmark
	case builders // https://lottiefiles.com/free-animation/builder-jQ4Y0BsPgS
	case usingMobilePhone // https://lottiefiles.com/free-animation/using-mobile-phone-zpKAugmnkE
	case paymentHero // https://lottiefiles.com/free-animation/payments-app-hero-8MXt0upX93
}

struct AnimationView: View {
    private let animation: AppAnimation
    private let loops: Bool

    init(
        _ animation: AppAnimation,
        loops: Bool = false
    ) {
        self.animation = animation
        self.loops = loops
    }

    var body: some View {
        LottieView(animation: .named(animation.rawValue))
            .playing(loopMode: loops ? .loop : .playOnce)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
