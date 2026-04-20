# Costivo - Construction Cost Estimator App

## Project Overview
Costivo is a practical iOS app designed for craftsmen and construction professionals to quickly create cost estimates for their clients. It replaces paper, Excel sheets, and calculators with a streamlined mobile solution.

## User: MR

## Core Problem Solved
Most craftsmen use manual methods (paper, Excel, calculator, WhatsApp notes) for creating quotes. Costivo provides:
- ✔️ Faster quotes
- ✔️ Less mistakes
- ✔️ Professional look
- ✔️ Saved history
- ✔️ More control over profit

## App Architecture

### Technology Stack
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Platform**: iOS
- **Language**: Swift

### Navigation Structure
Tab-based navigation with 3 main sections (MVP-focused):
1. **Jobs Tab** (Main Screen) - Create and manage client estimates - "Where users live"
2. **Materials Tab** - Manage materials price database
3. **Settings Tab** - Currency preferences & Labor rates management

## Core Features (MVP - Version 1)

### 1️⃣ Jobs (Main Screen - First Tab)
**Purpose**: "Where users live" - This is the primary workspace for daily work.

For each client, users can:
- Enter client name
- Select materials from their library
- Enter quantities for each material
- Add labor charges
- View automatic total calculation in real-time

**Calculation Example**:
```
Job for "Client XYZ":
- Concrete: 2 m³ × €20 = €40
- Labor: 5h × €25 = €125
─────────────────────────────
Total: €165
```

**Features**:
- Create new job estimates
- Save jobs with client name
- View all jobs with totals
- Edit existing jobs (modify quantities, add/remove items)
- Delete jobs
- Minimal job details (client name, materials, labor, total, date)

**This tab is optimized for**:
- Speed: Quick job creation
- Simplicity: Focus on "my work today"
- Clarity: Instant total calculation

### 2️⃣ Materials (Second Tab)
**Purpose**: Price database that saves time long-term.

Users can create their own materials library with:
- Material name (e.g., "Concrete", "Tiles", "Pipe", "Silicone")
- Price per unit
- Unit type selection:
  - **Length**: mm / cm / m / km
  - **Area**: m²
  - **Volume**: m³
  - **Per item**: piece

**Features**:
- Add new materials
- Edit existing materials
- Delete materials
- View all materials in a list

**Example Materials**:
- Concrete → €20 / m³
- Tiles → €15 / m²
- Pipe → €3 / meter
- Silicone → €5 / piece

### 3️⃣ Settings (Third Tab)
**Purpose**: Preferences and labor rate management.

**Currency Preferences**:
- Choose preferred currency (€, $, £, ¥, CHF, SEK, NOK, DKK)
- Auto-saves on change
- All prices display in selected currency throughout the app

**Labor Rates Management** (integrated into Settings):
- Define different labor pricing models:
  - **Hourly rate** → €25/hour
  - **Fixed price** → €200/job
  - **Per unit** → €5/m² install
- Add/Edit/Delete labor rates
- Support multiple pricing models

**Why labor rates are in Settings**:
- Less frequently modified than materials
- Keeps main tabs focused on daily work
- Reduces tab clutter for MVP
- Easy to access when needed

## Data Models

### Material
- id: UUID
- name: String
- pricePerUnit: Double
- unitType: UnitType enum
- specificUnit: String (e.g., "m", "m²", "piece")

### Labor Rate
- id: UUID
- name: String
- price: Double
- pricingModel: PricingModel enum (hourly, fixed, perUnit)
- unit: String? (for perUnit model)

### Job
- id: UUID
- clientName: String
- materials: [JobMaterial] (material reference + quantity)
- laborEntries: [JobLabor] (labor reference + quantity)
- totalCost: Double (calculated)
- createdDate: Date

### User Settings
- preferredCurrency: String

## Future Features (Post-MVP)
- Job status tracking (draft, sent, completed)
- Date filtering for jobs
- PDF/email quote generation
- Invoice generation
- Job templates
- Photo attachments
- Tax calculations
- Profit margin tracking

## Development Guidelines

### Code Style
- SwiftUI declarative patterns
- Swift async/await (avoid Combine)
- Clean separation of concerns
- Minimal comments for MVP
- Simple, focused implementations

### Key Principles
- **Keep it simple**: MVP focuses on core functionality only
- **No over-engineering**: Direct solutions, no premature abstractions
- **User-centric**: Fast, intuitive interface for busy craftsmen
- **Data integrity**: SwiftData for reliable local storage

## Project Status
✅ **MVP Complete** - Version 1.0 Ready

### Current Implementation Status
- ✅ SwiftData models implemented
- ✅ Jobs tab (main screen) with full CRUD
- ✅ Materials tab with full CRUD
- ✅ Settings tab with currency selection
- ✅ Labor rates management in Settings
- ✅ Real-time total calculation
- ✅ Tab-based navigation (3 tabs)
- ✅ All data persists locally with SwiftData

### App Structure
```
Costivo/
├── Models/
│   ├── Material.swift
│   ├── LaborRate.swift
│   ├── Job.swift
│   ├── JobMaterial.swift
│   ├── JobLabor.swift
│   ├── AppSettings.swift
│   ├── UnitType.swift
│   └── PricingModel.swift
├── Views/
│   ├── JobsView.swift (Main screen)
│   ├── AddJobView.swift
│   ├── JobDetailView.swift
│   ├── MaterialsView.swift
│   ├── AddMaterialView.swift
│   ├── EditMaterialView.swift
│   ├── MaterialPickerView.swift
│   ├── LaborPickerView.swift
│   ├── SettingsView.swift
│   ├── AddLaborRateView.swift
│   └── EditLaborRateView.swift
├── ContentView.swift (Tab navigation)
└── CostivoApp.swift (Entry point with SwiftData setup)
```

## Known Issues & Solutions

### SwiftData Schema Migration in Previews

**Problem**: After changing the Material model schema (from `unitTypeRaw` + `specificUnit` to just `unit`), Xcode previews stopped working. Materials could not be saved in previews even though the app worked fine in the simulator.

**Root Cause**:
- SwiftData previews were caching the old schema in memory
- The old schema had: `unitTypeRaw: String` and `specificUnit: String`
- The new schema has: `unit: String`
- Previews were trying to use the new model with old cached data

**Solution**:
Updated all preview configurations to use explicit in-memory containers:

```swift
#Preview("English") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, AppSettings.self,
        configurations: config
    )

    return MaterialsView()
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "en"))
}
```

**Why This Works**:
- `ModelConfiguration(isStoredInMemoryOnly: true)` creates a fresh database every time
- No stale schema data persists between preview reloads
- Each preview starts with the current model schema

**Files Updated**:
- `Costivo/Views/MaterialsView.swift` (lines 81-100)
- `Costivo/Views/AddMaterialView.swift` (lines 89-108)
- `Costivo/ContentView.swift` (lines 32-51)

**Prevention**:
- Always use `ModelConfiguration(isStoredInMemoryOnly: true)` for previews
- When changing @Model schemas, restart Xcode or clean build folder
- For the actual app, schema changes must be safe lightweight migrations (see SwiftData Schema Migration rules) — never delete user data

## Agent Architecture Rules

These rules are mandatory. The agent must follow them when writing or modifying any code in this project.

### File Placement
- All `@Model` classes → `Costivo/Models/`
- All SwiftUI views → `Costivo/Views/`
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
- Currency symbol is always read from `AppSettings` via `@Query` — never hardcode `€` or any symbol

### What the Agent Must NOT Do
- Do not add Combine, ObservableObject, or `@Published` — use SwiftData + `@State`/`@Bindable`
- Do not create helper/utility files for one-off operations
- Do not add a 4th tab without explicit instruction
- Do not change the SwiftData schema (add/remove/rename stored properties) without warning the user about migration risk
- Do not use `async/await` for SwiftData operations — SwiftData on main actor is synchronous

## Contact
User: MR
