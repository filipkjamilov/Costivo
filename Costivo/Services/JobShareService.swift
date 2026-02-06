import Foundation

struct JobShareService {
    /// Formats a job into a shareable text format
    static func formatJobForSharing(job: Job, currency: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var text = """
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        📋 \(L(.costEstimate))
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        \(L(.client)): \(job.clientName)
        \(L(.date)): \(dateFormatter.string(from: job.createdDate))
        
        """
        
        // Materials section
        if !job.materialEntries.isEmpty {
            text += """
            
            ━━━━━━━━━━━━━━━━━━━━━━━━━━
            🔨 \(L(.materials))
            ━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            """
            
            for material in job.materialEntries {
                let name = material.materialName.padding(toLength: 20, withPad: " ", startingAt: 0)
                let qty = String(format: "%.2f", material.quantity)
                let unit = material.unit.padding(toLength: 6, withPad: " ", startingAt: 0)
                let price = String(format: "%.2f", material.pricePerUnit)
                let total = String(format: "%.2f", material.totalPrice)
                text += "\(name) \(qty) \(unit) × \(price) = \(currency)\(total)\n"
            }
            
            let materialsTotal = job.materialEntries.reduce(0) { $0 + $1.totalPrice }
            let totalStr = String(format: "%.2f", materialsTotal)
            text += "\n\(L(.materialsTotal)) \(currency)\(totalStr)"
        }
        
        // Labor section
        if !job.laborEntries.isEmpty {
            text += """
            
            
            ━━━━━━━━━━━━━━━━━━━━━━━━━━
            👷 \(L(.labor))
            ━━━━━━━━━━━━━━━━━━━━━━━━━━
            
            """
            
            for labor in job.laborEntries {
                let name = labor.laborName.padding(toLength: 20, withPad: " ", startingAt: 0)
                let qty = String(format: "%.2f", labor.quantity)
                let unit = labor.unit.padding(toLength: 6, withPad: " ", startingAt: 0)
                let price = String(format: "%.2f", labor.pricePerUnit)
                let total = String(format: "%.2f", labor.totalPrice)
                text += "\(name) \(qty) \(unit) × \(price) = \(currency)\(total)\n"
            }
            
            let laborTotal = job.laborEntries.reduce(0) { $0 + $1.totalPrice }
            let totalStr = String(format: "%.2f", laborTotal)
            text += "\n\(L(.laborTotal)) \(currency)\(totalStr)"
        }
        
        // Total
        text += """
        
        
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        💰 \(L(.totalCost))
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        """
        
        let grandTotal = String(format: "%.2f", job.totalCost)
        text += "\(L(.totalLabel)) \(currency)\(grandTotal)"
        
        text += """
        
        
        ━━━━━━━━━━━━━━━━━━━━━━━━━━
        \(L(.generatedByCostivo))
        """
        
        return text
    }
}
