import SwiftUI

extension View {
    func appBackground() -> some View {
        self.background {
            AppGradientBackground()
        }
        .scrollContentBackground(.hidden)
    }
}

struct AppGradientBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        LinearGradient(
            colors: [
                AppColor.gradientTop(for: scheme),
                AppColor.gradientMid(for: scheme),
                AppColor.gradientBottom(for: scheme)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
