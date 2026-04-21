import Foundation
import SwiftData

@Model
final class AppSettings {
    var preferredCurrency: String
    var handymanTypeRaw: String
    var handymanName: String?
    var businessName: String?

    init(preferredCurrency: String = Currency.default.rawValue, handymanType: HandymanType = .construction) {
        self.preferredCurrency = preferredCurrency
        self.handymanTypeRaw = handymanType.rawValue
    }

    var handymanType: HandymanType {
        get { HandymanType(rawValue: handymanTypeRaw) ?? .construction }
        set { handymanTypeRaw = newValue.rawValue }
    }

    /// Default values used when no settings exist yet
    static let defaultCurrency = Currency.default.rawValue
    static let defaultHandymanType = HandymanType.construction
}

extension Array where Element == AppSettings {
    /// Single access point — returns the one AppSettings or provides defaults
    var currency: Currency {
        guard let raw = first?.preferredCurrency else { return .default }
        return Currency(rawValue: raw) ?? .default
    }

    var handymanType: HandymanType {
        first?.handymanType ?? AppSettings.defaultHandymanType
    }

    var handymanName: String? {
        first?.handymanName
    }

    var businessName: String? {
        first?.businessName
    }
}
