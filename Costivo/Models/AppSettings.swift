import Foundation
import SwiftData

@Model
final class AppSettings {
    var preferredCurrency: String
    var handymanTypeRaw: String

    init(preferredCurrency: String = "MKD", handymanType: HandymanType = .construction) {
        self.preferredCurrency = preferredCurrency
        self.handymanTypeRaw = handymanType.rawValue
    }

    var handymanType: HandymanType {
        get { HandymanType(rawValue: handymanTypeRaw) ?? .construction }
        set { handymanTypeRaw = newValue.rawValue }
    }

    /// Default values used when no settings exist yet
    static let defaultCurrency = "MKD"
    static let defaultHandymanType = HandymanType.construction
}

extension Array where Element == AppSettings {
    /// Single access point — returns the one AppSettings or provides defaults
    var currency: String {
        first?.preferredCurrency ?? AppSettings.defaultCurrency
    }

    var handymanType: HandymanType {
        first?.handymanType ?? AppSettings.defaultHandymanType
    }
}
