# Localization Service

## Overview

The `LocalizationService` provides a centralized, protocol-based approach to managing localized strings throughout the app. This makes it easy to:

- Maintain consistency in how strings are accessed
- Switch between different localization providers (e.g., Phrase, Lokalise)
- Test localization without changing the actual strings
- Add new languages or translation services

## Basic Usage

### Accessing Localized Strings

Use the shorthand `L` accessor throughout your code:

```swift
import Foundation

let L = LocalizationService.L

// Use localized strings
let clientLabel = L.client()           // Returns "Client" or "Клиент"
let shareButton = L.share()            // Returns "Share" or "Сподели"
let title = L.costEstimateWithClient("John Doe")  // Returns formatted title
```

### Example in a View

```swift
struct MyView: View {
    let L = LocalizationService.L
    
    var body: some View {
        VStack {
            Text(L.client())
            Button(L.share()) {
                // Share action
            }
        }
    }
}
```

## Architecture

### Protocol-Based Design

```swift
protocol LocalizationProvider {
    func localizedString(forKey key: String, comment: String) -> String
}
```

This protocol allows you to:
1. Keep the current iOS native localization (`DefaultLocalizationProvider`)
2. Add remote translation services (Phrase, Lokalise, etc.)
3. Mock localization for testing
4. A/B test different translations

### Current Implementation

```
┌─────────────────────────────┐
│   LocalizationService       │
│   (Singleton)               │
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
    
    func localizedString(forKey key: String, comment: String) -> String {
        // Fetch from Phrase with fallback to iOS native
        return phraseClient.getString(key) ?? NSLocalizedString(key, comment: comment)
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

All existing code continues to work without changes because it uses the `LocalizationService.L` accessor.

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
    func localizedString(forKey key: String, comment: String) -> String {
        return "TEST_\(key)"
    }
}

// In tests
LocalizationService.shared.setProvider(MockLocalizationProvider())
```

### 5. Remote Translations
Can load translations from a remote server on app launch without redeploying.

## Adding New Strings

### Step 1: Add to Localizable.xcstrings

Add the key and translations to `Localizable.xcstrings`

### Step 2: Add Method to LocalizationService

```swift
extension LocalizationService {
    func myNewString() -> String {
        provider.localizedString(forKey: "My New String", comment: "Description")
    }
}
```

### Step 3: Use It

```swift
let text = LocalizationService.L.myNewString()
```

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
