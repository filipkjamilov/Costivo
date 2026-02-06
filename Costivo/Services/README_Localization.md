# Localization Service

## Overview

The `LocalizationService` provides a **type-safe, enum-based** approach to managing localized strings throughout the app. This follows iOS best practices and makes it easy to:

- **Type Safety**: Compiler-checked localization keys (no typos!)
- **Autocomplete**: IDE suggestions for all available keys
- **Centralized**: All keys defined in one enum
- **Provider-Agnostic**: Easy integration with Phrase, Lokalise, etc.
- **Testable**: Mock providers for unit tests

Based on industry best practices from [Phrase](https://phrase.com/blog/posts/ios-app-localization-phrase/), [SwiftGen](https://github.com/SwiftGen/SwiftGen), and [modern Swift localization patterns](https://medium.com/@matsoftware/enumerable-localizable-keys-in-swift-4-2-23c7efd0604b).

## Basic Usage

### Simple Strings

Use the global `L()` function with enum keys:

```swift
// Simple string
let clientLabel = L(.client)           // "Client" or "Клиент"
let shareButton = L(.share)            // "Share" or "Сподели"
let settingsTitle = L(.settings)       // "Settings" or "Поставки"
```

### Formatted Strings

Pass arguments for strings with placeholders:

```swift
// String with format argument
let title = L(.costEstimateWithClient, "John Doe")
// Returns: "Cost Estimate - John Doe" or "Проценка на Трошоци - John Doe"
```

### Example in a View

```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text(L(.client))              // Type-safe!
            Button(L(.share)) {
                // Share action
            }
            Text(L(.costEstimateWithClient, clientName))
        }
    }
}
```

## Architecture

### Enum-Based Keys

All localization keys are defined in a single enum:

```swift
enum LocalizationKey: String {
    case client = "Client"
    case share = "Share"
    case costEstimateWithClient = "Cost Estimate - %@"
    case noMaterials = "No materials yet"
    case addMaterialToStart = "Add Material"
    // ... all other keys
}
```

**Benefits:**
- ✅ **Autocomplete**: IDE suggests all available keys
- ✅ **Type-safe**: Compiler catches typos at build time
- ✅ **Refactoring**: Rename keys safely across the entire codebase
- ✅ **Enumerable**: Can iterate all keys for testing

### Protocol-Based Provider

```swift
protocol LocalizationProvider {
    func localizedString(_ key: LocalizationKey) -> String
    func localizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String
}
```

This protocol allows you to:
1. Keep the current iOS native localization (`DefaultLocalizationProvider`)
2. Add remote translation services (Phrase, Lokalise, etc.)
3. Mock localization for testing
4. A/B test different translations

### Current Implementation

```
┌──────────────────────┐
│  L(.client)          │  ← Global function
│  L(.share)           │
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────────┐
│   LocalizationService       │
│   (Singleton)               │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  LocalizationKey (Enum)     │
│  • .client                  │
│  • .share                   │
│  • .costEstimateWithClient  │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  LocalizationProvider       │
│  (Protocol)                 │
└──────────┬──────────────────┘
           │
           ├──► DefaultLocalizationProvider (iOS native)
           ├──► PhraseProvider (future)
           └──► CustomProvider (future)
```

## Future: Integrating with Phrase

### Step 1: Create a Phrase Provider

```swift
import PhraseSDK  // Hypothetical Phrase SDK

class PhraseLocalizationProvider: LocalizationProvider {
    private let phraseClient: PhraseClient
    
    init(apiKey: String, projectId: String) {
        self.phraseClient = PhraseClient(apiKey: apiKey, projectId: projectId)
    }
    
    func localizedString(_ key: LocalizationKey) -> String {
        // Fetch from Phrase with fallback to iOS native
        return phraseClient.getString(key.rawValue) ?? NSLocalizedString(key.rawValue, comment: "")
    }
    
    func localizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        let format = phraseClient.getString(key.rawValue) ?? NSLocalizedString(key.rawValue, comment: "")
        return String(format: format, arguments: args)
    }
}
```

### Step 2: Configure on App Launch

```swift
// In CostivoApp.swift or AppDelegate

#if PRODUCTION
let provider = PhraseLocalizationProvider(
    apiKey: "your-phrase-api-key",
    projectId: "your-project-id"
)
#else
let provider = DefaultLocalizationProvider()
#endif

LocalizationService.shared.setProvider(provider)
```

### Step 3: That's It!

All existing code continues to work without changes because it uses the `L()` function with enum keys.

## Benefits

### 1. Easy Migration
No need to search and replace `NSLocalizedString` calls throughout the codebase.

### 2. Centralized Management
All translation keys are defined in one place, making it easy to:
- See which strings are used
- Add new strings
- Refactor keys

### 3. Type Safety
Methods like `costEstimateWithClient(_:)` ensure proper formatting and type safety.

### 4. Testing
Easy to mock for unit tests:

```swift
class MockLocalizationProvider: LocalizationProvider {
    func localizedString(_ key: LocalizationKey) -> String {
        return "TEST_\(key.rawValue)"
    }
    
    func localizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        return "TEST_\(key.rawValue)_WITH_ARGS"
    }
}

// In tests
LocalizationService.shared.setProvider(MockLocalizationProvider())

// Test that all keys have translations (requires CaseIterable)
func testAllKeysHaveTranslations() {
    for key in LocalizationKey.allCases {
        let translation = L(key)
        XCTAssertFalse(translation.isEmpty)
    }
}
```

### 5. Remote Translations
Can load translations from a remote server on app launch without redeploying.

## Adding New Strings

### Step 1: Add to LocalizationKey Enum

```swift
enum LocalizationKey: String {
    // ... existing keys
    case myNewFeature = "My New Feature"
    case welcomeMessage = "Welcome to %@"
}
```

### Step 2: Add to Localizable.xcstrings

Add the key and translations to `Localizable.xcstrings`:
- English: "My New Feature"
- Macedonian: "Моја Нова Карактеристика"

### Step 3: Use It

```swift
// Simple string
let text = L(.myNewFeature)

// With arguments
let message = L(.welcomeMessage, userName)
```

**That's it!** The compiler ensures type safety throughout your app.

## Integration Services Comparison

| Service | Real-time Updates | Collaboration | Cost | Integration Effort |
|---------|-------------------|---------------|------|-------------------|
| **iOS Native** | No (requires app update) | Limited | Free | Current (✅) |
| **Phrase** | Yes (OTA) | Excellent | Paid | Medium |
| **Lokalise** | Yes (OTA) | Excellent | Paid | Medium |
| **POEditor** | Yes (OTA) | Good | Freemium | Medium |
| **Custom API** | Yes (OTA) | Custom | Variable | High |

## Best Practices

1. **Always use LocalizationService.L** instead of NSLocalizedString directly
2. **Group related strings** with comments in LocalizationService
3. **Use descriptive method names** that indicate context
4. **Keep format strings type-safe** with dedicated methods
5. **Test both languages** during development

## Migration Path

If you want to migrate existing `NSLocalizedString` calls:

```bash
# Find all NSLocalizedString calls
grep -r "NSLocalizedString" --include="*.swift" .

# Replace gradually with LocalizationService methods
```

## Questions?

For issues or suggestions, contact the development team or create an issue in the project repository.
