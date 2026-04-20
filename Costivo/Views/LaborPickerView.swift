import SwiftUI
import SwiftData

struct LaborPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let laborRates: [LaborRate]
    let onSelect: (LaborRate) -> Void
    
    var body: some View {
        NavigationStack {
            List(laborRates) { labor in
                Button {
                    onSelect(labor)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(labor.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(formattedPrice(for: labor))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .appBackground()
            .navigationTitle(L(.selectLabor))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.cancel)) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if laborRates.isEmpty {
                    ContentUnavailableView(
                        L(.noLaborRatesAvailable),
                        systemImage: "wrench.and.screwdriver",
                        description: Text(L(.addLaborRatesFirst))
                    )
                }
            }
        }
    }
    
    private func formattedPrice(for labor: LaborRate) -> String {
        let priceStr = String(format: "%.2f", labor.price)
        
        switch labor.pricingModel {
        case .hourly:
            return "\(priceStr) / \(L(.hour))"
        case .fixed:
            return "\(priceStr) / \(L(.job))"
        case .perUnit:
            return "\(priceStr) / \(labor.unit ?? L(.unitLabel))"
        }
    }
}
