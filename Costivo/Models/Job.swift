import Foundation
import SwiftData

@Model
final class Job {
    var id: UUID
    var clientName: String
    var createdDate: Date
    var dueDate: Date?
    var statusRaw: String = JobStatus.draft.rawValue
    var materialEntries: [JobMaterial]
    var laborEntries: [JobLabor]

    var totalCost: Double {
        let materialsTotal = materialEntries.reduce(0) { $0 + $1.totalPrice }
        let laborTotal = laborEntries.reduce(0) { $0 + $1.totalPrice }
        return materialsTotal + laborTotal
    }

    var status: JobStatus {
        get { JobStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var isOverdue: Bool {
        guard let dueDate, status != .completed, status != .archived else { return false }
        return dueDate < Date()
    }

    init(clientName: String, dueDate: Date? = nil, status: JobStatus = .draft) {
        self.id = UUID()
        self.clientName = clientName
        self.createdDate = Date()
        self.dueDate = dueDate
        self.statusRaw = status.rawValue
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
