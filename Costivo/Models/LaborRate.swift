import Foundation
import SwiftData

@Model
final class LaborRate {
    var id: UUID
    var name: String
    var price: Double
    var pricingModelRaw: String
    var unit: String?
    
    var pricingModel: PricingModel {
        get { PricingModel(rawValue: pricingModelRaw) ?? .hourly }
        set { pricingModelRaw = newValue.rawValue }
    }
    
    init(name: String, price: Double, pricingModel: PricingModel, unit: String? = nil) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.pricingModelRaw = pricingModel.rawValue
        self.unit = unit
    }
}
