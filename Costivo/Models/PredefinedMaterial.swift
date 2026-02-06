import Foundation
import SwiftUI

struct PredefinedMaterial: Identifiable {
    let id = UUID()
    let nameKey: String
    let nameEn: String
    let nameMk: String
    let unit: String
    let suggestedPrice: Double?
    
    func localizedName(locale: Locale = .current) -> String {
        let languageCode = locale.language.languageCode?.identifier ?? locale.languageCode
        if languageCode == "mk" {
            return nameMk
        }
        return nameEn
    }
    
    static let predefined: [PredefinedMaterial] = [
        PredefinedMaterial(nameKey: "concrete", nameEn: "Concrete", nameMk: "Бетон", unit: "m³", suggestedPrice: 20),
        PredefinedMaterial(nameKey: "stiropor", nameEn: "Stiropor (Styrofoam)", nameMk: "Стиропор", unit: "m²", suggestedPrice: 15),
        PredefinedMaterial(nameKey: "tiles", nameEn: "Tiles", nameMk: "Плочки", unit: "m²", suggestedPrice: 25),
        PredefinedMaterial(nameKey: "glue", nameEn: "Glue", nameMk: "Лепак", unit: "kg", suggestedPrice: 5),
        PredefinedMaterial(nameKey: "silicon", nameEn: "Silicon", nameMk: "Силикон", unit: "piece", suggestedPrice: 3),
        PredefinedMaterial(nameKey: "detergent", nameEn: "Detergent", nameMk: "Детергент", unit: "piece", suggestedPrice: 4),
        PredefinedMaterial(nameKey: "cement", nameEn: "Cement", nameMk: "Цемент", unit: "kg", suggestedPrice: 0.5),
        PredefinedMaterial(nameKey: "sand", nameEn: "Sand", nameMk: "Песок", unit: "m³", suggestedPrice: 15),
        PredefinedMaterial(nameKey: "bricks", nameEn: "Bricks", nameMk: "Тули", unit: "piece", suggestedPrice: 0.3),
        PredefinedMaterial(nameKey: "paint", nameEn: "Paint", nameMk: "Боја", unit: "kg", suggestedPrice: 8),
        PredefinedMaterial(nameKey: "plaster", nameEn: "Plaster", nameMk: "Малтер", unit: "m²", suggestedPrice: 5),
        PredefinedMaterial(nameKey: "wood_boards", nameEn: "Wood Boards", nameMk: "Дрвени Даски", unit: "m²", suggestedPrice: 12),
        PredefinedMaterial(nameKey: "pipes_pvc", nameEn: "Pipes (PVC)", nameMk: "Цевки (PVC)", unit: "m", suggestedPrice: 3),
        PredefinedMaterial(nameKey: "electrical_cable", nameEn: "Electrical Cable", nameMk: "Електричен Кабел", unit: "m", suggestedPrice: 2),
        PredefinedMaterial(nameKey: "insulation", nameEn: "Insulation", nameMk: "Изолација", unit: "m²", suggestedPrice: 10)
    ]
}
