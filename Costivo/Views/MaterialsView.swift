import SwiftUI
import SwiftData

struct MaterialsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Material.name) private var materials: [Material]
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
            .navigationTitle("Materials")
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
                        "No Materials",
                        systemImage: "cube.box",
                        description: Text("Add your first material to get started")
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
        settings.first?.preferredCurrency ?? "€"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(material.name)
                    .font(.headline)
                Text("\(material.unitType.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(currency)\(material.pricePerUnit, specifier: "%.2f") / \(material.specificUnit)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MaterialsView()
        .modelContainer(for: [Material.self, AppSettings.self])
}
