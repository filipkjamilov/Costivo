import Foundation

enum UnitType: String, Codable, CaseIterable {
    case length = "Length"
    case area = "Area"
    case volume = "Volume"
    case piece = "Per Item"
    
    var availableUnits: [String] {
        switch self {
        case .length:
            return ["mm", "cm", "m", "km"]
        case .area:
            return ["m²"]
        case .volume:
            return ["m³"]
        case .piece:
            return ["piece"]
        }
    }
}
