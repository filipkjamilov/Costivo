import Foundation
import SwiftData

@Model
final class AppSettings {
    var preferredCurrency: String
    
    init(preferredCurrency: String = "MKD") {
        self.preferredCurrency = preferredCurrency
    }
}
