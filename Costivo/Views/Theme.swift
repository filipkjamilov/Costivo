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
            colors: scheme == .dark
                ? [Color(hex: 0x3D3010), Color(hex: 0x1E1B14), Color(hex: 0x111111)]
                : [Color(hex: 0xF2D8A0), Color(hex: 0xF0E4CC), Color(hex: 0xF2F2F7)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension Color {
    init(hex: Int) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255
        )
    }
}
