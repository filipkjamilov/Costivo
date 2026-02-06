import Foundation

enum PricingModel: String, Codable, CaseIterable {
    case hourly = "Hourly Rate"
    case fixed = "Fixed Price"
    case perUnit = "Per Unit"
    
    var requiresUnit: Bool {
        self == .perUnit
    }
}
