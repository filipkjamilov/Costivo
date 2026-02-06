import Foundation
import SwiftData

@Model
final class Job {
    var id: UUID
    var clientName: String
    var createdDate: Date
    var materialEntries: [JobMaterial]
    var laborEntries: [JobLabor]
    
    var totalCost: Double {
        let materialsTotal = materialEntries.reduce(0) { $0 + $1.totalPrice }
        let laborTotal = laborEntries.reduce(0) { $0 + $1.totalPrice }
        return materialsTotal + laborTotal
    }
    
    init(clientName: String) {
        self.id = UUID()
        self.clientName = clientName
        self.createdDate = Date()
        self.materialEntries = []
        self.laborEntries = []
    }
}

@Model
final class JobMaterial {
    var id: UUID
    var materialName: String
    var pricePerUnit: Double
    var unit: String
    var quantity: Double
    
    var totalPrice: Double {
        pricePerUnit * quantity
    }
    
    init(materialName: String, pricePerUnit: Double, unit: String, quantity: Double) {
        self.id = UUID()
        self.materialName = materialName
        self.pricePerUnit = pricePerUnit
        self.unit = unit
        self.quantity = quantity
    }
}

@Model
final class JobLabor {
    var id: UUID
    var laborName: String
    var pricePerUnit: Double
    var unit: String
    var quantity: Double
    
    var totalPrice: Double {
        pricePerUnit * quantity
    }
    
    init(laborName: String, pricePerUnit: Double, unit: String, quantity: Double) {
        self.id = UUID()
        self.laborName = laborName
        self.pricePerUnit = pricePerUnit
        self.unit = unit
        self.quantity = quantity
    }
}
