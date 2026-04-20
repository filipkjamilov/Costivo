import SwiftUI
import SwiftData

struct MaterialsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Material.name) private var materials: [Material]
    @Query private var settings: [AppSettings]
    @State private var showingAddMaterial = false
    @State private var editingMaterial: Material?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(materials) { material in
                    MaterialRow(material: material)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingMaterial = material
                        }
                }
                .onDelete(perform: deleteMaterials)
            }
            .appBackground()
            .navigationTitle(L(.materialsTitle))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMaterial = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMaterial) {
                AddMaterialView()
            }
            .sheet(item: $editingMaterial) { material in
                EditMaterialView(material: material)
            }
            .overlay {
                if materials.isEmpty {
                    ContentUnavailableView(
                        L(.noMaterialsYet),
                        systemImage: settings.handymanType.materialsIcon,
                        description: Text(L(.addFirstMaterial))
                    )
                }
            }
        }
    }
    
    private func deleteMaterials(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(materials[index])
        }
    }
}

struct MaterialRow: View {
    let material: Material
    @Query private var settings: [AppSettings]
    
    private var currency: String {
        settings.currency
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(material.name)
                    .font(.headline)
            }
            
            Spacer()
            
            Text("\(currency)\(material.pricePerUnit, specifier: "%.2f") / \(Unit.localizedUnit(material.unit))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

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

#Preview("Macedonian") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Material.self, LaborRate.self, Job.self, AppSettings.self,
        configurations: config
    )
    
    return MaterialsView()
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "mk"))
}
