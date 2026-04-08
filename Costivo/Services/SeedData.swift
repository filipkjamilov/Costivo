import SwiftData
import Foundation

struct SeedData {

    static func populate(into context: ModelContext) {
        let materials = insertMaterials(into: context)
        let laborRates = insertLaborRates(into: context)
        insertJobs(into: context, materials: materials, laborRates: laborRates)
        insertSettings(into: context)
        try? context.save()
    }

    // MARK: - Materials

    @discardableResult
    private static func insertMaterials(into context: ModelContext) -> [Material] {
        let specs: [(String, Double, String)] = [
            ("Concrete", 20.0, "m³"),
            ("Tiles", 15.0, "m²"),
            ("Copper Pipe", 3.50, "m"),
            ("Silicone Sealant", 5.0, "piece"),
            ("Gravel", 12.0, "m³"),
            ("Plasterboard", 8.0, "m²"),
            ("PVC Pipe", 2.0, "m"),
            ("Insulation Foam", 6.50, "m²"),
            ("Sand", 9.0, "m³"),
            ("Screws (box)", 4.0, "piece"),
        ]

        return specs.map { name, price, unit in
            let m = Material(name: name, pricePerUnit: price, unit: unit)
            context.insert(m)
            return m
        }
    }

    // MARK: - Labor Rates

    @discardableResult
    private static func insertLaborRates(into context: ModelContext) -> [LaborRate] {
        let specs: [(String, Double, PricingModel, String?)] = [
            ("General Labor", 25.0, .hourly, nil),
            ("Specialist Labor", 45.0, .hourly, nil),
            ("Fixed Site Visit", 80.0, .fixed, nil),
            ("Tiling Installation", 12.0, .perUnit, "m²"),
            ("Pipe Installation", 8.0, .perUnit, "m"),
        ]

        return specs.map { name, price, model, unit in
            let r = LaborRate(name: name, price: price, pricingModel: model, unit: unit)
            context.insert(r)
            return r
        }
    }

    // MARK: - Jobs

    private static func insertJobs(into context: ModelContext, materials: [Material], laborRates: [LaborRate]) {
        guard !materials.isEmpty, !laborRates.isEmpty else { return }

        let jobSpecs: [(String, Int)] = [
            ("John Smith - Bathroom Renovation", 0),
            ("ABC Construction - Foundation Work", -3),
            ("Maria Lopez - Kitchen Tiling", -7),
        ]

        for (clientName, daysOffset) in jobSpecs {
            let job = Job(clientName: clientName)
            if daysOffset != 0, let offsetDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) {
                job.createdDate = offsetDate
            }
            context.insert(job)

            for material in materials.prefix(2) {
                let quantity = Double(Int.random(in: 1...5))
                let entry = JobMaterial(
                    materialName: material.name,
                    pricePerUnit: material.pricePerUnit,
                    unit: material.unit,
                    quantity: quantity
                )
                context.insert(entry)
                job.materialEntries.append(entry)
            }

            if let rate = laborRates.first {
                let hours = Double(Int.random(in: 2...8))
                let entry = JobLabor(
                    laborName: rate.name,
                    pricePerUnit: rate.price,
                    unit: rate.unit ?? "h",
                    quantity: hours
                )
                context.insert(entry)
                job.laborEntries.append(entry)
            }
        }
    }

    // MARK: - Settings

    private static func insertSettings(into context: ModelContext) {
        let existingCount = (try? context.fetchCount(FetchDescriptor<AppSettings>())) ?? 0
        guard existingCount == 0 else { return }
        context.insert(AppSettings())
    }
}
