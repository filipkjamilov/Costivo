import Foundation

enum SubscriptionStatus {
    case notDetermined
    case trial(expiresAt: Date)
    case subscribed(expiresAt: Date, willRenew: Bool)
    case expired
    case revoked

    var canAccessApp: Bool {
        switch self {
        case .notDetermined, .trial, .subscribed:
            return true
        case .expired, .revoked:
            return false
        }
    }

    var displayName: String {
        switch self {
        case .notDetermined:
            return ""
        case .trial:
            return L(.subscriptionTrial)
        case .subscribed:
            return L(.subscriptionActive)
        case .expired:
            return L(.subscriptionExpired)
        case .revoked:
            return L(.subscriptionExpired)
        }
    }
}
