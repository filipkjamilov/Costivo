import SwiftUI

enum AppColor: String {
    // MARK: - Neutral
    case white = "#FFFFFF"
    case black = "#000000"

    // MARK: - Construction Yellow (Brand)
    case yellowSoft = "#FFF8EB"
    case yellowLight = "#F2D8A0"
    case yellowMuted = "#F0E4CC"
    case yellowBase = "#E5A820"
    case yellowDeep = "#C48A18"

    // MARK: - Warm Grey (Text & Backgrounds)
    case greySoft = "#F2F2F7"
    case greyLight = "#D1C9BE"
    case greyMuted = "#8A7A6E"
    case greyBase = "#3D3010"
    case greyDark = "#1E1B14"
    case greyDeep = "#111111"

    // MARK: - Success Green
    case greenSoft = "#E8FCE9"
    case greenLight = "#ABEDBA"
    case greenBase = "#34C759"
    case greenBold = "#28A745"
    case greenDeep = "#1E7E34"

    // MARK: - Attention Red
    case redSoft = "#FBE7E9"
    case redLight = "#F2AEB4"
    case redBase = "#E5616F"
    case redBold = "#D81329"
    case redDeep = "#A90F21"

    // MARK: - Info Blue
    case blueSoft = "#E8F0FE"
    case blueLight = "#A8C8F0"
    case blueBase = "#5A9EE0"
    case blueBold = "#2D7DD2"
    case blueDeep = "#1A5FA6"

    // MARK: - Warning Orange
    case orangeSoft = "#FFF3E0"
    case orangeLight = "#FFD0A0"
    case orangeBase = "#FF9500"
    case orangeBold = "#E08600"
    case orangeDeep = "#C27200"

    case clear

    var color: Color {
        if self == .clear { return Color.clear }
        let hex = rawValue.dropFirst()
        let scanner = Scanner(string: String(hex))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// MARK: - Semantic Colors (Adaptive Light/Dark)

extension AppColor {
    static func gradientTop(for scheme: ColorScheme) -> Color {
        scheme == .dark ? greyBase.color : yellowLight.color
    }

    static func gradientMid(for scheme: ColorScheme) -> Color {
        scheme == .dark ? greyDark.color : yellowMuted.color
    }

    static func gradientBottom(for scheme: ColorScheme) -> Color {
        scheme == .dark ? greyDeep.color : greySoft.color
    }
}

// MARK: - Color Extension (enables .tint(.orangeBase), .foregroundStyle(.redBold), etc.)

extension Color {
    // Yellow
    static let yellowSoft = AppColor.yellowSoft.color
    static let yellowLight = AppColor.yellowLight.color
    static let yellowMuted = AppColor.yellowMuted.color
    static let yellowBase = AppColor.yellowBase.color
    static let yellowDeep = AppColor.yellowDeep.color

    // Grey
    static let greySoft = AppColor.greySoft.color
    static let greyLight = AppColor.greyLight.color
    static let greyMuted = AppColor.greyMuted.color
    static let greyBase = AppColor.greyBase.color
    static let greyDark = AppColor.greyDark.color
    static let greyDeep = AppColor.greyDeep.color

    // Green
    static let greenSoft = AppColor.greenSoft.color
    static let greenLight = AppColor.greenLight.color
    static let greenBase = AppColor.greenBase.color
    static let greenBold = AppColor.greenBold.color
    static let greenDeep = AppColor.greenDeep.color

    // Red
    static let redSoft = AppColor.redSoft.color
    static let redLight = AppColor.redLight.color
    static let redBase = AppColor.redBase.color
    static let redBold = AppColor.redBold.color
    static let redDeep = AppColor.redDeep.color

    // Blue
    static let blueSoft = AppColor.blueSoft.color
    static let blueLight = AppColor.blueLight.color
    static let blueBase = AppColor.blueBase.color
    static let blueBold = AppColor.blueBold.color
    static let blueDeep = AppColor.blueDeep.color

    // Orange
    static let orangeSoft = AppColor.orangeSoft.color
    static let orangeLight = AppColor.orangeLight.color
    static let orangeBase = AppColor.orangeBase.color
    static let orangeBold = AppColor.orangeBold.color
    static let orangeDeep = AppColor.orangeDeep.color
}
