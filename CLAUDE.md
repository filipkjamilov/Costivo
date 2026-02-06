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

## Contact
User: MR
