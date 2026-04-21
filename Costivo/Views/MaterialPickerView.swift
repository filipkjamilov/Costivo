import SwiftUI
import SwiftData

struct MaterialPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let materials: [Material]
    let onSelect: (Material) -> Void
    
    var body: some View {
        NavigationStack {
            List(materials) { material in
                Button {
                    onSelect(material)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(material.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(String(format: "%.2f", material.pricePerUnit)) / \(Unit.localizedUnit(material.unit))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.blueBold)
                    }
                }
            }
            .appBackground()
            .navigationTitle(L(.selectMaterial))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if materials.isEmpty {
                    ContentUnavailableView(
                        L(.noMaterialsAvailable),
                        systemImage: "shippingbox",
                        description: Text(L(.addMaterialsFirst))
                    )
                }
            }
        }
    }
}
