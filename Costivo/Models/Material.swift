import Foundation
import SwiftData

@Model
final class Material {
    @Attribute(.unique) var id: UUID
    var name: String
    var pricePerUnit: Double
    var unit: String
    
    init(name: String, pricePerUnit: Double, unit: String) {
        self.id = UUID()
        self.name = name
        self.pricePerUnit = pricePerUnit
        self.unit = unit
    }
}
