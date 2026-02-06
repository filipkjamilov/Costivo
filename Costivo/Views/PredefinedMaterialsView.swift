import SwiftUI

struct PredefinedMaterialsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    let onSelect: (PredefinedMaterial) -> Void
    
    var body: some View {
        NavigationStack {
            List(PredefinedMaterial.predefined) { material in
                Button {
                    onSelect(material)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(material.localizedName(locale: locale))
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            HStack(spacing: 8) {
                                Text(Unit.localizedUnit(material.unit))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                if let price = material.suggestedPrice {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("~\(price, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .navigationTitle(L(.commonMaterials))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("English") {
    PredefinedMaterialsView { _ in }
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("Macedonian") {
    PredefinedMaterialsView { _ in }
        .environment(\.locale, Locale(identifier: "mk"))
}
