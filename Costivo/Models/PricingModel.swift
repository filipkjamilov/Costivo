import Foundation
import SwiftUI

enum PricingModel: String, Codable, CaseIterable {
    case hourly = "Hourly Rate"
    case fixed = "Fixed Price"
    case perUnit = "Per Unit"
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    var requiresUnit: Bool {
        self == .perUnit
    }
}
