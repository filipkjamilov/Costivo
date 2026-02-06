import Foundation
import SwiftUI

struct Unit {
    static let allUnits = ["mm", "cm", "m", "km", "m²", "m³", "piece", "kg", "Lt"]
    
    static func localizedUnitKey(_ unit: String) -> LocalizedStringKey {
        if unit == "piece" {
            return "piece"
        }
        return LocalizedStringKey(unit)
    }
    
    static func localizedUnit(_ unit: String) -> String {
        if unit == "piece" {
            return String(localized: "piece")
        }
        return unit
    }
}
