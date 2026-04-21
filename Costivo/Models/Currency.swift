import Foundation

enum Currency: String, CaseIterable {
    case usd = "$"
    case eur = "€"
    case rsd = "RSD"
    case mkd = "MKD"

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .rsd: return "дин"
        case .mkd: return "ден"
        }
    }

    var label: String {
        rawValue
    }

    static let `default`: Currency = .usd
}
