import Foundation
import SwiftData

@Model
final class Material {
    var id: UUID
    var name: String
    var pricePerUnit: Double
    var unitTypeRaw: String
    var specificUnit: String
    
    var unitType: UnitType {
        get { UnitType(rawValue: unitTypeRaw) ?? .piece }
        set { unitTypeRaw = newValue.rawValue }
    }
    
    init(name: String, pricePerUnit: Double, unitType: UnitType, specificUnit: String) {
        self.id = UUID()
        self.name = name
        self.pricePerUnit = pricePerUnit
        self.unitTypeRaw = unitType.rawValue
        self.specificUnit = specificUnit
    }
}
