import SwiftUI

struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.5, blue: 0.8), Color(red: 0.1, green: 0.3, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 0) {
                // Calculator/Document icon
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                
                // Small calculator symbol overlay
                Image(systemName: "plus.forwardslash.minus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .offset(y: -10)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    AppIconGenerator()
}
