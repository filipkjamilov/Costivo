# Review Job Calculation Skill

Audit the total cost calculation logic for correctness. Follow these steps:

1. Read `Costivo/Models/Job.swift` — find where `totalCost` is computed or assigned
2. Read `Costivo/Models/JobMaterial.swift` — check how quantity × pricePerUnit is calculated
3. Read `Costivo/Models/JobLabor.swift` — check how labor cost is calculated per pricing model (hourly, fixed, perUnit)
4. Cross-check `Costivo/Views/AddJobView.swift` and `Costivo/Views/JobDetailView.swift` — verify the UI reflects the same calculation logic and updates in real-time
5. Look for these specific bugs:
   - Floating point rounding issues in displayed totals
   - Labor entries with `pricingModel == .fixed` incorrectly multiplying by quantity
   - `totalCost` being stale (set once and not recalculated after edits)
6. Report findings: what is correct, what is wrong, and proposed fixes if any
