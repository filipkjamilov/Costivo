# Add Material Unit Skill

The user wants to add a new unit type to the app. Follow these steps exactly:

1. Open `Costivo/Models/UnitType.swift` and identify the existing enum cases and categories
2. Ask the user: what is the new unit name, what category does it belong to (Length / Area / Volume / Per item), and what is its display symbol?
3. Add the new case to `UnitType` enum in the correct category
4. Check `Costivo/Views/AddMaterialView.swift` and `Costivo/Views/EditMaterialView.swift` — verify the new unit appears in the unit picker without additional changes (it should if the picker iterates all cases)
5. Confirm no hardcoded unit lists exist elsewhere by searching for existing unit names
6. Report what was changed and which files were touched
