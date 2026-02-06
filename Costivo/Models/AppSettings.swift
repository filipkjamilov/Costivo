import Foundation
import SwiftData

@Model
final class AppSettings {
    var preferredCurrency: String
    
    init(preferredCurrency: String = "€") {
        self.preferredCurrency = preferredCurrency
    }
}
