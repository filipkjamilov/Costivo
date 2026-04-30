# Costivo - Construction Cost Estimator App

## Project Overview
Costivo is a practical iOS app designed for craftsmen and construction professionals to quickly create cost estimates for their clients. It replaces paper, Excel sheets, and calculators with a streamlined mobile solution.

## User: MR

## Contact
- Support email: appcostivo@gmail.com
- App Store: https://apps.apple.com/app/id6758861678
- Website / Privacy Policy: https://filipkjamilov.com/CostivoWeb/
- Privacy Policy URL: https://filipkjamilov.com/CostivoWeb/privacy-policy.html

## Current Version
- Marketing version: 2.0.0
- Build number: 5

## Core Problem Solved
Most craftsmen use manual methods (paper, Excel, calculator, WhatsApp notes) for creating quotes. Costivo provides:
- Faster quotes
- Less mistakes
- Professional look
- Saved history
- More control over profit

## App Architecture

### Technology Stack
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Animations**: Lottie (via SPM, static target only — NOT `Lottie-Dynamic`)
- **Subscriptions**: RevenueCat SDK (via SPM — `RevenueCat` + `RevenueCatUI`)
- **Platform**: iOS
- **Language**: Swift

### Navigation Structure
Tab-based navigation with 3 main sections:
1. **Jobs Tab** (Main Screen) - Create and manage client estimates - "Where users live"
2. **Materials Tab** - Manage materials price database
3. **Settings Tab** - Currency, profession, labor rates management

### Onboarding Flow
First-time users see a 5-step onboarding + trial offer before the main app, managed by `OnboardingView`:
1. **Tutorial movie** — 3 auto-playing Lottie animation slides with text (non-interactive until finished)
2. **Business profile** — handyman name + optional company name with avatar circle showing initials
3. **Profession picker** — select trade (construction, plumber, electrician, etc.)
4. **Currency picker** — select preferred currency with live preview
5. **Feature walkthrough** — 4-page animated walkthrough showing materials/labor, job creation, swipe-to-complete, and swipe-to-archive with mock UI demos
6. **TrialOfferView** — shown after walkthrough as a fullScreenCover; user starts free trial or sees pricing

Onboarding logic lives in `OnboardingView.swift` — `ContentView` delegates to it and only shows the TabView once complete.

Onboarding state is stored in `@AppStorage` (UserDefaults), NOT SwiftData — no schema changes needed.
- `hasSeenTutorial`, `hasSetProfile`, `hasPickedProfession`, `hasPickedCurrency`, `hasSeenWalkthrough`

**Critical timing detail**: `hasSeenWalkthrough` is NOT set when the walkthrough ends — it is set only when `TrialOfferView.onComplete` fires. This keeps `OnboardingView` in the hierarchy so the `fullScreenCover` can present over it. Setting it too early causes `ContentView` to remove `OnboardingView` before the cover can appear.

**Backward compatibility**: `ContentView` uses `.onAppear` to auto-set `hasSeenWalkthrough = true` for existing users who already have `hasPickedCurrency = true`, so they skip the walkthrough. Existing users also get `startTrial()` called in `ContentView.onAppear` → fresh 30-day trial from update date.

### Dual-Mode View Pattern
`BusinessProfileView`, `ProfessionPickerView`, and `CurrencyPickerView` all support two modes via an optional `onComplete` closure:
- **Onboarding mode** (`onComplete` provided): Full-screen layout with "Continue" button, no navigation bar
- **Settings mode** (`onComplete` is `nil`): Wrapped in `NavigationStack` with "Done" toolbar button and `dismiss()`

This avoids duplicating views. When adding similar picker views, follow the same pattern.

## Core Features

### Jobs (Main Screen - First Tab)
**Purpose**: "Where users live" - This is the primary workspace for daily work.

For each client, users can:
- Enter client name
- Select materials from their library
- Enter quantities for each material
- Add labor charges
- Set optional due date
- View automatic total calculation in real-time

**Job Status Tracking**:
- Draft (default for new jobs)
- Scheduled (auto-set when due date is added)
- Completed (via swipe action)
- Archived (via swipe action on completed jobs)

**Filtering**: Toolbar menu with filters: All, Upcoming, Overdue, Completed, Archived

### Materials (Second Tab)
**Purpose**: Price database that saves time long-term.

Users can create their own materials library with:
- Material name
- Price per unit
- Unit type (mm, cm, m, km, m², m³, piece)

Also includes predefined common materials for quick-add.

### Settings (Third Tab)
**Purpose**: Preferences and labor rate management.

- **Profile**: Shows `ProfileAvatar` with name/company, opens `BusinessProfileView` sheet
- **Currency**: Opens `CurrencyPickerView` as a sheet ($, €, RSD, MKD) — managed by `Currency` enum
- **Profession**: Opens `ProfessionPickerView` as a sheet
- **Labor Rates**: NavigationLink pushes to `LaborRatesView` with count badge and full CRUD (hourly, fixed, per unit)
- **Subscription**: Shows status (Active/Trial/Expired), trial expiry date, manage subscription (CustomerCenter), or subscribe button
- **Feedback**: Link to feedback form

### Subscription System
**Model**: Free download → 30-day local trial (no card required) → Paid subscription (annual $29.99/year or lifetime $99.99)

**Products** (App Store Connect + RevenueCat):
- `costivo_pro_yearly` — Auto-Renewable Subscription, $29.99/year
- `costivo_pro_lifetime` — Non-Consumable, $99.99 one-time

**RevenueCat IDs**:
- Project: `projc2576bb8`
- App Store app: `appfc7f73fe8e` (bundle: `com.ciconia.Costivo`)
- Entitlement: `"Costivo Pro"` (`entl6dfd2738d4`)
- Offering: `default` (`ofrng5021cc0e01`) — packages `$rc_annual` + `$rc_lifetime`
- Live SDK key: `appl_VvvheQvFCULLTnORFHMqmdUVXCF` (in `SubscriptionManager.apiKey`)
- App Store Connect API key configured in RC dashboard (Key ID: S4YS22BM8X)

**Architecture**:
- **RevenueCat SDK** handles all purchase logic, receipt validation, and entitlement management
- **`SubscriptionManager`** (`@Observable @MainActor`) — central service injected via `.environment()` from `CostivoApp`
- **Entitlement ID**: `"Costivo Pro"` — checked via `Purchases.shared.customerInfo()`
- **Local trial**: 30-day trial tracked via UserDefaults (`subscriptionTrialStartDate`), independent of StoreKit
- **No SwiftData changes** — subscription state comes from RevenueCat + UserDefaults only
- **Single API key**: Always uses the live key `appl_VvvheQvFCULLTnORFHMqmdUVXCF` — no test key. The RC test key caused Error 23 because the RC Test Store has no products configured. Never reintroduce a test key.

**Flow**:
1. User completes 5-step onboarding
2. `TrialOfferView` appears as fullScreenCover
3. User taps "Start Free Trial" → `subscriptionManager.startTrial()` → `hasSeenWalkthrough = true` → enters app
4. During trial: full access, Settings shows trial expiry
5. Trial expired + no subscription: `ContentView` shows `PaywallView(isDismissible: false)` blocking all content
6. Subscribed: full access, Settings shows "Manage Subscription" (opens RevenueCat CustomerCenter)

**Content gating in `ContentView`** — 3-way gate:
1. Onboarding not complete → `OnboardingView`
2. Onboarding complete AND `canAccessApp` → `TabView`
3. Onboarding complete AND NOT `canAccessApp` → `PaywallView(isDismissible: false)`

**PaywallView behaviour**:
- `isDismissible: true` (from TrialOfferView "See Pricing") — shows custom X close button in top-right corner so user can go back to start free trial
- `isDismissible: false` (expired trial) — no close button, user must subscribe
- `#if DEBUG && !QA_BUILD` — shows `DebugPaywallView` instead of RC paywall (RC paywall fails in simulator because StoreKit can't fetch sandbox products without a real device + sandbox Apple ID)

**Debug**: `DebugConsoleView` has full subscription section — RC user ID, entitlement status, debug overrides (Subscribed Yearly/Lifetime/Trial 30d/7d/1d/Expired/Revoked/Clear), trial controls (start/set expiry/reset), refresh RC customer info.

## Data Models

### Material
- id: UUID
- name: String
- pricePerUnit: Double
- unit: String

### Labor Rate
- id: UUID
- name: String
- price: Double
- pricingModelRaw: String (computed `pricingModel: PricingModel`)
- unit: String?

### Job
- id: UUID
- clientName: String
- materials: [JobMaterial] (material reference + quantity)
- laborEntries: [JobLabor] (labor reference + quantity)
- totalCost: Double (calculated)
- createdDate: Date
- dueDate: Date? (optional)
- statusRaw: String = "draft" (computed `status: JobStatus`)

### AppSettings
- preferredCurrency: String (raw value from `Currency` enum, default `"$"`)
- handymanTypeRaw: String (computed `handymanType: HandymanType`)
- handymanName: String? (craftsman's display name)
- businessName: String? (optional company name)
- Access via `[AppSettings]` extension: `settings.currency` returns `Currency`, `settings.handymanType` returns `HandymanType`, `settings.handymanName` / `settings.businessName` return `String`

### SubscriptionStatus (enum, not SwiftData)
- `notDetermined` — app just launched, checking status (allows access to prevent paywall flash)
- `trial(expiresAt: Date)` — in free trial period
- `subscribed(expiresAt: Date, willRenew: Bool)` — active subscription
- `expired` — trial or subscription expired
- `revoked` — subscription revoked by Apple
- Computed: `canAccessApp` (true for notDetermined/trial/subscribed), `displayName` (localized)

### Enums (separate files)
- `Currency`: usd ($), eur (€), rsd (RSD), mkd (MKD) — has `.symbol`, `.label`, `.default`
- `JobStatus`: draft, scheduled, completed, archived
- `HandymanType`: construction, plumber, electrician, painter, carpenter, tiler
- `PricingModel`: hourly, fixed, perUnit
- `UnitType`: length, area, volume, perItem

### Currency Rules
- All currency logic lives in `Models/Currency.swift` — never hardcode "$", "€", "MKD", etc. in views
- Views access `settings.currency.symbol` for display (e.g., "$", "ден")
- SwiftData stores the raw string (`Currency.rawValue`); the `[AppSettings].currency` extension returns the typed enum
- To add a new currency, add a case to `Currency` — the picker, preview, and all views update automatically

## Development Guidelines

### Code Style
- SwiftUI declarative patterns
- Swift async/await (avoid Combine)
- Clean separation of concerns
- Minimal comments for MVP
- Simple, focused implementations

### Key Principles
- **Keep it simple**: Direct solutions, no premature abstractions
- **User-centric**: Fast, intuitive interface for busy craftsmen
- **Data integrity**: SwiftData for reliable local storage
- **No data loss**: All schema changes must be safe lightweight migrations

### Color Palette (MANDATORY)
**All colors in the app MUST come from the `AppColor` enum** in `Views/AppColor.swift`. Never use raw hex values, `Color.red`, `Color.blue`, `.green`, `.orange`, or any other system/hardcoded color directly.

Usage: `.tint(.orangeBase)`, `.foregroundStyle(.redBold)` — Color extensions allow direct use in SwiftUI modifiers.

| Group | Soft | Light | Muted | Base | Bold/Deep |
|---|---|---|---|---|---|
| **Yellow (Brand)** | `yellowSoft` | `yellowLight` | `yellowMuted` | `yellowBase` | `yellowDeep` |
| **Grey** | `greySoft` | `greyLight` | `greyMuted` | `greyBase` | `greyDark` / `greyDeep` |
| **Green (Success)** | `greenSoft` | `greenLight` | — | `greenBase` | `greenBold` / `greenDeep` |
| **Red (Attention)** | `redSoft` | `redLight` | — | `redBase` | `redBold` / `redDeep` |
| **Blue (Info)** | `blueSoft` | `blueLight` | — | `blueBase` | `blueBold` / `blueDeep` |
| **Orange (Warning)** | `orangeSoft` | `orangeLight` | — | `orangeBase` | `orangeBold` / `orangeDeep` |

**Naming convention:** soft (lightest bg) → light → muted → base (primary) → bold → deep (darkest).

**Dark/Light mode gradient** is handled by `AppColor.gradientTop/Mid/Bottom(for:)` — dark mode uses greyBase(`#3D3010`)→greyDark(`#1E1B14`)→greyDeep(`#111111`) which are warm brown tones (not neutral grey), light mode uses yellowLight(`#F2D8A0`)→yellowMuted(`#F0E4CC`)→greySoft(`#F2F2F7`).

**Rules:**
- Use `Color` extensions for SwiftUI modifiers: `.tint(.blueBold)`, `.foregroundStyle(.greenBase)`
- For Lottie animation customization, reference `AppColor` hex strings via `.rawValue`
- System semantic colors (`.primary`, `.secondary`) are OK for text — they adapt to dark mode natively
- `Color.accentColor` is OK for interactive elements that should follow the app's accent color
- `Color.clear` and `Color(.secondarySystemGroupedBackground)` are OK for system-level transparency and backgrounds

### RevenueCat / Subscriptions
- Only import `RevenueCat` in `SubscriptionManager.swift` — keep RC types out of all other files
- Only import `RevenueCatUI` in `PaywallView.swift` and `SettingsView.swift` (for `CustomerCenterView`)
- Subscription state is NOT stored in SwiftData — it comes from RevenueCat + UserDefaults
- `SubscriptionManager` is `@Observable` (not `ObservableObject`) — injected via `.environment()` from `CostivoApp`
- Entitlement ID is `"Costivo Pro"` — defined in `SubscriptionManager.entitlementID`
- Local trial uses UserDefaults key `subscriptionTrialStartDate` — not `@AppStorage` (needs Date, not Bool)
- PaywallView uses `RevenueCatUI.PaywallView` — paywall template is configured in the RevenueCat dashboard
- Debug overrides (`debugOverride: SubscriptionStatus?`) allow QA testing without real purchases
- `#if DEBUG && !QA_BUILD` shows `DebugPaywallView` — never shows the real RC paywall in Xcode debug builds

### Lottie Animations
- All animation JSON files go in `Costivo/Animations/`
- Enum cases in `AppAnimation` must match JSON filenames exactly (no `.json` extension)
- `AnimationView` wraps Lottie — consumers use `loops: Bool` parameter, never import Lottie directly
- Only import `Lottie` in `AnimationView.swift` — keep Lottie types out of all other files

### Localization
- All user-facing strings use `L(.keyName)` via `LocalizationService`
- Keys are defined in `LocalizationKey` enum in `Services/LocalizationService.swift`
- Translations in `Localizable.xcstrings` with `extractionState: "manual"`
- Supported languages: English (en), Macedonian (mk)

## App Structure
```
Costivo/
├── Animations/
│   ├── builders.json
│   ├── checkmark.json
│   ├── paymentHero.json
│   └── usingMobilePhone.json
├── Models/
│   ├── AppSettings.swift
│   ├── Currency.swift
│   ├── HandymanType.swift
│   ├── Job.swift
│   ├── JobStatus.swift
│   ├── LaborRate.swift
│   ├── Material.swift
│   ├── PredefinedMaterial.swift
│   ├── PricingModel.swift
│   ├── SubscriptionStatus.swift
│   └── UnitType.swift
├── Services/
│   ├── JobShareService.swift
│   ├── LocalizationService.swift
│   ├── SeedData.swift
│   ├── ShakeDetector.swift
│   └── SubscriptionManager.swift (RevenueCat integration — only file that imports RevenueCat)
├── Views/
│   ├── AddJobView.swift
│   ├── AddLaborRateView.swift
│   ├── AddMaterialView.swift
│   ├── AnimationView.swift (Lottie wrapper — only file that imports Lottie)
│   ├── AppColor.swift (Color palette)
│   ├── BusinessProfileView.swift (Dual-mode: onboarding + settings, contains ProfileAvatar)
│   ├── CurrencyPickerView.swift (Dual-mode: onboarding + settings)
│   ├── DebugConsoleView.swift (Shake to open, full subscription + onboarding + data reset)
│   ├── EditLaborRateView.swift
│   ├── EditMaterialView.swift
│   ├── FeatureWalkthroughView.swift (4-page animated feature demo)
│   ├── JobDetailView.swift
│   ├── JobsView.swift (Main screen)
│   ├── LaborPickerView.swift
│   ├── LaborRatesView.swift
│   ├── MaterialPickerView.swift
│   ├── MaterialsView.swift
│   ├── OnboardingView.swift (5-step onboarding + TrialOfferView trigger)
│   ├── PaywallView.swift (RC paywall wrapper + DebugPaywallView for #if DEBUG && !QA_BUILD)
│   ├── PredefinedMaterialsView.swift
│   ├── ProfessionPickerView.swift (Dual-mode: onboarding + settings)
│   ├── SettingsView.swift
│   ├── ShareSheet.swift
│   ├── Theme.swift (.appBackground() modifier)
│   ├── TrialOfferView.swift (Post-onboarding trial offer screen)
│   └── TutorialView.swift (Auto-playing onboarding movie)
├── ContentView.swift (3-way gate: Onboarding → Subscription → TabView)
└── CostivoApp.swift (Entry point with SwiftData + RevenueCat setup)
```

## Known Issues & Solutions

### SwiftData Schema Migration in Previews

**Problem**: After changing model schemas, Xcode previews cache the old schema and fail.

**Solution**: All previews use `ModelConfiguration(isStoredInMemoryOnly: true)`:
```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, JobMaterial.self, JobLabor.self, AppSettings.self,
        configurations: config
    )
    return SomeView()
        .modelContainer(container)
}
```

**Prevention**:
- Always use in-memory containers for previews
- When changing @Model schemas, restart Xcode or clean build folder

### Debug Console & Build Schemes
The app has two schemes:
- **Costivo** — standard scheme (`Debug` / `Release` configurations), app name "Costivo"
- **Costivo Dev** — QA scheme (`Dev` configuration, has `QA_BUILD` compiler flag), app name "Costivo Dev", bundle ID `com.ciconia.Costivo.dev`

The Dev configuration has both `DEBUG` and `QA_BUILD` in `SWIFT_ACTIVE_COMPILATION_CONDITIONS`.

The debug console is triggered by a shake gesture, gated by `#if DEBUG || QA_BUILD`. This ensures it works:
- When running from Xcode (any scheme, via `DEBUG`)
- In TestFlight Dev builds (via `QA_BUILD` baked into the binary)
- Never in production Release builds

Use `#if DEBUG && !QA_BUILD` for behavior that should only apply in Xcode debug runs (e.g. `DebugPaywallView`) — NOT in TestFlight QA builds.

The debug console supports: viewing app info, RC user ID, entitlement status, debug overrides for all subscription states, trial controls (start/set expiry/reset), onboarding step reset, database stats, populate test data, clear all data, full reset (UserDefaults + SwiftData).

### RC Paywall Error 23 in Simulator
RevenueCat Error 23 (`CONFIGURATION_ERROR`) occurs in the Xcode simulator because StoreKit can't fetch real App Store products without a physical device + sandbox Apple ID. This is expected and handled by `DebugPaywallView` (`#if DEBUG && !QA_BUILD`). For real paywall testing: use a physical device with a sandbox tester account (App Store Connect → Users and Access → Sandbox Testers).

### Lottie UIViewRepresentable Steals Touches
Lottie's SwiftUI wrapper uses a UIKit view that intercepts touch events. `allowsHitTesting(false)` on the SwiftUI level may not work on the animation itself. Solution: put interactive elements (buttons) in a separate overlay ZStack layer on top of the animation content, or apply `.allowsHitTesting(false)` to the entire content VStack and overlay the button separately.

## Agent Architecture Rules

These rules are mandatory. The agent must follow them when writing or modifying any code in this project.

### File Placement
- All `@Model` classes → `Costivo/Models/`
- All SwiftUI views → `Costivo/Views/`
- Animation JSON files → `Costivo/Animations/`
- Services → `Costivo/Services/`
- No new directories unless explicitly approved
- One type per file; filename must match the type name exactly

### Adding a New Model
1. Create `Costivo/Models/ModelName.swift` with `@Model final class`
2. Register it in `CostivoApp.swift` inside `ModelContainer(for:)` alongside existing models
3. If the model is a child (e.g., a join/entry type like `JobMaterial`), add a `@Relationship(deleteRule: .cascade)` on the parent side

### Adding a New View
1. Create `Costivo/Views/ViewName.swift`
2. Follow existing naming pattern: list views end in `View`, add/edit sheets end in `AddXView` / `EditXView`, pickers end in `PickerView`
3. Every new view file must include a `#Preview` using an in-memory `ModelContainer` (see Known Issues & Solutions)
4. Inject the model context via `@Environment(\.modelContext)` — do not pass it as a parameter

### Adding a New Animation
1. Add the JSON file to `Costivo/Animations/`
2. Add a case to `AppAnimation` enum in `AnimationView.swift` — the raw value must match the filename exactly
3. Use `AnimationView(.caseName, loops: true/false)` in views — never import Lottie outside `AnimationView.swift`

### SwiftData Rules
- Never use `try!` except inside `#Preview` blocks
- Always use `@Query` for fetching lists in views — do not fetch manually in `onAppear`
- Use `modelContext.insert()` to add, `modelContext.delete()` to remove
- `totalCost` on `Job` is always computed on save — never store a stale value

### SwiftData Schema Migration (CRITICAL)
**Users must NEVER lose their data.** The app is in production with real users. Every schema change must be a safe lightweight migration:
- **New properties must be optional (`Type?`) or have a default value** — this is the only safe way to add fields
- **Never rename or remove existing stored properties** — this breaks the schema and causes data loss
- **Never tell the user to "delete and reinstall"** — that destroys their data
- **Use the raw String + computed property pattern** for enums (e.g., `statusRaw: String` with computed `status: JobStatus`) — set a default value on the raw property so existing rows get a valid state
- If a migration cannot be done safely with lightweight migration, stop and discuss with the user before proceeding

### SwiftUI Patterns
- Use `@State` for local view state, `@Bindable` for SwiftData model editing
- Sheets and navigation pushes are the only two navigation patterns — no custom routers
- Currency is always accessed via `settings.currency` (returns `Currency` enum) — use `.symbol` for display, never hardcode "$", "€", etc.
- Use `@AppStorage` for lightweight boolean flags (onboarding state, feature flags) — NOT SwiftData
- Use `[AppSettings]` array extension for convenience access: `settings.currency`, `settings.handymanType`

### What the Agent Must NOT Do
- Do not add Combine, ObservableObject, or `@Published` — use SwiftData + `@State`/`@Bindable`
- Do not create helper/utility files for one-off operations
- Do not add a 4th tab without explicit instruction
- Do not change the SwiftData schema (add/remove/rename stored properties) without warning the user about migration risk
- Do not use `async/await` for SwiftData operations — SwiftData on main actor is synchronous
- Do not import Lottie outside of `AnimationView.swift`
- Do not import `RevenueCat` outside of `SubscriptionManager.swift` — keep RC types isolated
- Do not store subscription state in SwiftData — it comes from RevenueCat + UserDefaults
- Do not duplicate views — use the dual-mode pattern (optional `onComplete` closure) when a view is needed in both onboarding and settings
- Do not reintroduce a RevenueCat test API key — always use the live key; the RC test store has no products configured and causes Error 23
