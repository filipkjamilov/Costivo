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
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Select Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if materials.isEmpty {
                    ContentUnavailableView(
                        "No Materials Available",
                        systemImage: "cube.box",
                        description: Text("Add materials first in the Materials tab")
                    )
                }
            }
        }
    }
}
