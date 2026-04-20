import Foundation

// MARK: - Localization Key Enum

/// Centralized enum for all localization keys
/// Provides type-safe localization with enum case names as keys
/// Keys in Localizable.xcstrings should match the case names exactly
enum LocalizationKey: String, CaseIterable {
    // MARK: - Common
    case client
    case date
    case share
    case done
    case total
    case settings
    
    // MARK: - Share/Export
    case costEstimate
    case materials
    case materialsTotal
    case labor
    case laborTotal
    case totalCost
    case totalLabel
    case generatedByCostivo
    case costEstimateWithClient
    
    // MARK: - Settings
    case support
    case sendFeedback
    case preferences
    case currency
    case selectPreferredCurrency
    case laborRates
    case manageLaborPricing
    case shareFeedbackPrompt
    case addLaborRate
    case noLaborRates
    case addFirstLaborRate
    
    // MARK: - Materials
    case noMaterials
    case addMaterialButton
    case addLabor
    case materialsSection
    case laborSection
    case totalCostSection
    case commonMaterials
    case cancel
    
    // MARK: - Jobs
    case jobs
    case noJobs
    case createFirstJob
    case searchByClientName
    case jobDetails
    case clientName
    case quantity
    case newJob
    case save
    case add
    
    // MARK: - Materials View
    case materialsTitle
    case noMaterialsYet
    case addFirstMaterial
    case quickAdd
    case chooseFromCommon
    case selectFromCommonMaterials
    case materialDetails
    case materialNamePlaceholder
    case pricePerUnit
    case unit
    
    // MARK: - Labor
    case hour
    case job
    case unitLabel
    
    // MARK: - Picker Views
    case selectMaterial
    case selectLabor
    case noMaterialsAvailable
    case noLaborRatesAvailable
    case addMaterialsFirst
    case addLaborRatesFirst
    
    // MARK: - Handyman Types
    case profession
    case construction
    case plumber
    case electrician
    case painter
    case carpenter
    case tiler
    case chooseProfession
    case professionDescription
    case preview

    // MARK: - Edit Views
    case editMaterial
    case editLaborRate
    case name
    case price
    case laborDetails
    case laborNamePlaceholder
    case pricingModel
    case model
    case unitPlaceholder
}

// MARK: - Localization Protocol

/// Protocol for localization providers
/// Allows easy integration with Phrase, Lokalise, etc.
protocol LocalizationProvider {
    func localizedString(_ key: LocalizationKey) -> String
    func localizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String
}

// MARK: - Default Provider

/// Default localization provider using iOS String Catalogs
struct DefaultLocalizationProvider: LocalizationProvider {
    func localizedString(_ key: LocalizationKey) -> String {
        return NSLocalizedString(key.rawValue, comment: "")
    }
    
    func localizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key.rawValue, comment: "")
        return String(format: format, arguments: args)
    }
}

// MARK: - Localization Service

/// Centralized localization service
/// Usage: L(.client) or L(.costEstimateWithClient, "John Doe")
class LocalizationService {
    static let shared = LocalizationService()
    
    private var provider: LocalizationProvider
    
    private init(provider: LocalizationProvider = DefaultLocalizationProvider()) {
        self.provider = provider
    }
    
    /// Update the localization provider (e.g., to use Phrase)
    func setProvider(_ provider: LocalizationProvider) {
        self.provider = provider
    }
    
    /// Get localized string for a key
    func callAsFunction(_ key: LocalizationKey) -> String {
        return provider.localizedString(key)
    }
    
    /// Get localized string with format arguments
    func callAsFunction(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        return provider.localizedString(key, args)
    }
}

// MARK: - Convenience

/// Global shorthand for localization
/// Usage: L(.client) or L(.costEstimateWithClient, clientName)
func L(_ key: LocalizationKey) -> String {
    return LocalizationService.shared(key)
}

func L(_ key: LocalizationKey, _ args: CVarArg...) -> String {
    return LocalizationService.shared(key, args)
}
