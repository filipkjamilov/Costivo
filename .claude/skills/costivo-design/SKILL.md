---
name: costivo-design
description: "Costivo iOS app design system for SwiftUI. Covers the construction-yellow gradient background, .appBackground() modifier, HandymanType profession system with dynamic icons, and standard iOS Form/List styling. Use when creating, reviewing, or improving any UI in the Costivo app."
---

# Costivo Design System

iOS SwiftUI design guide for Costivo — a construction cost estimator for craftsmen. The visual language is **clean, warm, and professional**: a construction-yellow gradient background that adapts to dark/light mode, with standard iOS Form/List styling. No custom card components or color asset tokens — the design stays simple and relies on the gradient background for brand identity.

---

## When to Apply

Invoke this skill for any task that involves:
- Creating a new view or component
- Reviewing existing UI for consistency
- Choosing colors, spacing, or typography
- Implementing list rows, forms, or buttons
- Adding new screens to the app

---

## 1. Background System

The entire app uses a **construction-yellow linear gradient** applied per-view via the `.appBackground()` modifier. There are NO color asset tokens (no `.colorset` files) — all colors live in `Theme.swift` using `Color(hex:)`.

### The `.appBackground()` Modifier

Every `Form` and `List` in the app MUST call `.appBackground()`. This modifier:
1. Applies `AppGradientBackground` as a `.background{}` view
2. Calls `.scrollContentBackground(.hidden)` so the gradient shows through

```swift
// Theme.swift
extension View {
    func appBackground() -> some View {
        self.background {
            AppGradientBackground()
        }
        .scrollContentBackground(.hidden)
    }
}
```

### Gradient Colors

| Mode | Top | Middle | Bottom |
|---|---|---|---|
| Light | `#F2D8A0` | `#F0E4CC` | `#F2F2F7` |
| Dark | `#3D3010` | `#1E1B14` | `#111111` |

Direction: `.top` to `.bottom` (LinearGradient).

### Critical Rule: Apply on Form/List, NOT on TabView

The gradient MUST be applied as `.background{}` directly on each `Form` or `List`, NOT behind the `TabView` in a `ZStack`. TabView has an opaque background that covers anything behind it. The `.appBackground()` modifier handles this correctly.

```swift
// Correct
Form { ... }
    .appBackground()

// Wrong - gradient won't be visible
ZStack {
    AppGradientBackground()
    TabView { ... }
}
```

### Color(hex:) Helper

```swift
extension Color {
    init(hex: Int) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255
        )
    }
}
```

---

## 2. HandymanType Profession System

The app dynamically adapts its icons based on the user's selected profession. This is powered by the `HandymanType` enum in `Models/HandymanType.swift`.

### Supported Professions

| Type | Jobs Icon | Materials Icon | Settings Icon |
|---|---|---|---|
| construction | `hammer` | `shippingbox` | `wrench.and.screwdriver` |
| plumber | `wrench.adjustable` | `pipe.and.drop` | `spigot` |
| electrician | `bolt` | `cable.connector` | `powerplug` |
| painter | `paintbrush` | `paintpalette` | `eyedropper` |
| carpenter | `ruler` | `tree` | `hammer` |
| tiler | `square.grid.2x2` | `square.stack.3d.up` | `square.on.square` |

### How It Works

1. `AppSettings` stores `handymanTypeRaw: String` with a computed `handymanType` property
2. Views query settings via `@Query private var settings: [AppSettings]`
3. Icons are accessed via `settings.first?.handymanType.jobsIcon ?? "hammer"`
4. Tab bar icons in `ContentView` use the same pattern
5. Empty state icons in `JobsView` and `MaterialsView` also adapt

### ProfessionPickerView

A dedicated view (`Views/ProfessionPickerView.swift`) for selecting profession:
- 2-column `LazyVGrid` of `ProfessionCard` items
- Animated selection with accent color highlight
- Live `TabBarPreview` showing how tab icons will look
- Opened as a `.sheet` from Settings
- Will be reused for onboarding tutorial

---

## 3. Typography

Use SF Pro (system default). Never import custom fonts.

| Role | SwiftUI Style | Weight |
|---|---|---|
| Screen title | `.navigationTitle` | System (`.large` for tab roots, `.inline` for sheets) |
| Section header | Form section header | System default |
| List item name | `.headline` | `.regular` |
| Price / amount | `.subheadline` | `.regular` |
| Caption / unit | `.caption` | `.regular` |

No custom color tokens for typography — use `.primary`, `.secondary`, and system defaults.

---

## 4. Component Patterns

### 4.1 List/Form Screens

Standard iOS `Form` and `List` styling. No custom card rows or card modifiers.

```swift
NavigationStack {
    Form {
        Section { ... } header: { Text(L(.sectionName)) }
    }
    .appBackground()
    .navigationTitle(L(.screenTitle))
    .navigationBarTitleDisplayMode(.large)
}
```

### 4.2 Empty States

Use `ContentUnavailableView` with profession-adaptive icons:

```swift
.overlay {
    if items.isEmpty {
        ContentUnavailableView(
            L(.noItemsYet),
            systemImage: settings.first?.handymanType.jobsIcon ?? "hammer",
            description: Text(L(.addFirstItem))
        )
    }
}
```

### 4.3 Navigation

- Tab root screens: `.navigationBarTitleDisplayMode(.large)`
- Sheet screens: `.navigationBarTitleDisplayMode(.inline)`
- All navigation via sheets (`.sheet`) or `NavigationLink` — no custom routers

### 4.4 Tab Bar

3 tabs in `ContentView`, icons driven by `HandymanType`:

```swift
TabView {
    Tab(L(.jobs), systemImage: handymanType.jobsIcon) { JobsView() }
    Tab(L(.materialsTitle), systemImage: handymanType.materialsIcon) { MaterialsView() }
    Tab(L(.settings), systemImage: handymanType.settingsIcon) { SettingsView() }
}
```

---

## 5. Localization

All user-facing strings use the `L(.key)` function with `LocalizationKey` enum cases:

```swift
Text(L(.clientName))       // Simple string
L(.costEstimateWithClient, name)  // With format arguments
```

Keys are defined in `Services/LocalizationService.swift`. Translations live in `Localizable.xcstrings` (String Catalog).

---

## 6. SwiftUI Implementation Rules

1. **Every Form/List calls `.appBackground()`** — no exceptions
2. **No color asset tokens** — all custom colors use `Color(hex:)` in `Theme.swift` only
3. **No `.cardRow()`, `.themedForm()`, or `TotalCostCard`** — these do not exist; use standard iOS styling
4. **Icons adapt to profession** — use `settings.first?.handymanType` for all SF Symbol references
5. **Currency from settings** — always read from `AppSettings` via `@Query`, never hardcode
6. **Previews use in-memory containers** — `ModelConfiguration(isStoredInMemoryOnly: true)`
7. **Sheets inherit system background** — `.appBackground()` is for Form/List content, not sheet chrome

---

## 7. Do's and Don'ts

| Do | Don't |
|---|---|
| Use `.appBackground()` on every Form/List | Put gradient behind TabView in a ZStack |
| Use standard iOS Form/List styling | Create custom card row modifiers |
| Use `Color(hex:)` only in Theme.swift | Create `.colorset` asset files or `Color.*` tokens |
| Use `settings.first?.handymanType` for icons | Hardcode SF Symbol names for tab/empty state icons |
| Use `L(.key)` for all user-facing strings | Use raw string literals |
| Use `.large` title for tab roots | Use `.inline` on main tab screens |
| Keep Form sections with standard headers/footers | Over-style sections with custom backgrounds |

---

## 8. Review Checklist

When reviewing UI, verify:
- [ ] Screen has `.appBackground()` on its Form or List
- [ ] Gradient is visible (warm yellow in light mode, dark warm tone in dark mode)
- [ ] Icons use HandymanType from settings (not hardcoded)
- [ ] No color asset files exist in `Assets.xcassets` (except `AccentColor` and `AppIcon`)
- [ ] All strings use `L(.key)` localization pattern
- [ ] Preview uses `ModelConfiguration(isStoredInMemoryOnly: true)`
- [ ] Currency reads from `AppSettings`, not hardcoded
