import SwiftUI

struct FeatureWalkthroughView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @State private var animationTrigger = false
    @State private var isAnimating = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 0) {
                Spacer()

                // Page content
                ZStack {
                    if currentPage == 0 {
                        MaterialsLaborPage(animationTrigger: $animationTrigger, isAnimating: $isAnimating)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentPage == 1 {
                        CreateJobPage(animationTrigger: $animationTrigger, isAnimating: $isAnimating)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentPage == 2 {
                        SwipeCompletePage(animationTrigger: $animationTrigger, isAnimating: $isAnimating)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else if currentPage == 3 {
                        SwipeArchivePage(animationTrigger: $animationTrigger, isAnimating: $isAnimating)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }

                Spacer()

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.yellowBase : Color.greyLight)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                // Next / Start button
                Button {
                    advancePage()
                } label: {
                    Text(currentPage == totalPages - 1
                         ? L(.walkthroughStart)
                         : L(.walkthroughNext))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.yellowBase, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isAnimating)
                .opacity(isAnimating ? 0.6 : 1.0)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)

                // Skip
                if currentPage < totalPages - 1 {
                    Button {
                        onComplete()
                    } label: {
                        Text(L(.walkthroughSkip))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 24)
                } else {
                    Spacer()
                        .frame(height: 48)
                }
            }
        }
        .onAppear {
            triggerPageAnimation()
        }
    }

    private func advancePage() {
        if currentPage < totalPages - 1 {
            animationTrigger = false
            withAnimation(.easeInOut(duration: 0.4)) {
                currentPage += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                triggerPageAnimation()
            }
        } else {
            onComplete()
        }
    }

    private func triggerPageAnimation() {
        animationTrigger = true
    }
}

// MARK: - Page 1: Materials & Labor

private struct MaterialsLaborPage: View {
    @Binding var animationTrigger: Bool
    @Binding var isAnimating: Bool
    @State private var visibleRows = 0

    private let mockRows: [MockItemRow] = [
        .material("Cement Bags", "piece", "$12.50"),
        .material("PVC Pipe 2\"", "m", "$8.75"),
        .labor("Plumbing", "hourly", "$45.00"),
        .labor("Tiling", "fixed", "$350.00"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text(L(.walkthroughMaterialsTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(L(.walkthroughMaterialsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 8) {
                ForEach(Array(mockRows.enumerated()), id: \.offset) { index, item in
                    if index < visibleRows {
                        MockRow {
                            switch item {
                            case .material(let name, let unit, let price):
                                HStack(spacing: 12) {
                                    Image(systemName: "cube.box.fill")
                                        .foregroundStyle(Color.blueBold)
                                        .font(.title3)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(name)
                                            .font(.headline)
                                        Text(unit)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(price)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            case .labor(let name, let model, let price):
                                HStack(spacing: 12) {
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .foregroundStyle(Color.orangeBase)
                                        .font(.title3)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(name)
                                            .font(.headline)
                                        Text(model)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(price)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .onChange(of: animationTrigger) { _, triggered in
            if triggered { revealRows() }
        }
        .onAppear {
            if animationTrigger { revealRows() }
        }
    }

    private func revealRows() {
        visibleRows = 0
        isAnimating = true
        for i in 0..<mockRows.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * Double(i)) {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    visibleRows = i + 1
                }
                if i == mockRows.count - 1 {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Page 2: Create a Job

private struct CreateJobPage: View {
    @Binding var animationTrigger: Bool
    @Binding var isAnimating: Bool
    @State private var showClient = false
    @State private var showMaterials = false
    @State private var showLabor = false
    @State private var showTotal = false

    var body: some View {
        VStack(spacing: 20) {
            Text(L(.walkthroughJobTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(L(.walkthroughJobSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Mock job card
            VStack(spacing: 0) {
                if showClient {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Marco Rossi")
                                .font(.headline)
                            HStack(spacing: 6) {
                                Text("Apr 15, 2026")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Label {
                                    Text("Apr 28")
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                .font(.caption)
                                .foregroundStyle(Color.orangeBase)
                            }
                        }
                        Spacer()
                    }
                    .padding(14)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if showMaterials {
                    Divider()
                        .padding(.horizontal, 14)
                    VStack(spacing: 6) {
                        mockChip("Cement Bags", qty: "10", price: "$125.00", icon: "cube.box.fill", color: .blueBold)
                        mockChip("PVC Pipe", qty: "25m", price: "$218.75", icon: "cube.box.fill", color: .blueBold)
                    }
                    .padding(14)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                if showLabor {
                    Divider()
                        .padding(.horizontal, 14)
                    VStack(spacing: 6) {
                        mockChip("Plumbing", qty: "8h", price: "$360.00", icon: "wrench.and.screwdriver.fill", color: .orangeBase)
                    }
                    .padding(14)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                if showTotal {
                    Divider()
                        .padding(.horizontal, 14)
                    HStack {
                        Text(L(.total))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("$703.75")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.yellowDeep)
                    }
                    .padding(14)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.regularMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)
        }
        .onChange(of: animationTrigger) { _, triggered in
            if triggered { buildCard() }
        }
        .onAppear {
            if animationTrigger { buildCard() }
        }
    }

    private func buildCard() {
        showClient = false
        showMaterials = false
        showLabor = false
        showTotal = false
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) { showClient = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) { showMaterials = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) { showLabor = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                showTotal = true
            }
            isAnimating = false
        }
    }

    private func mockChip(_ name: String, qty: String, price: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
            Text("× \(qty)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(price)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Page 3: Swipe to Complete

private struct SwipeCompletePage: View {
    @Binding var animationTrigger: Bool
    @Binding var isAnimating: Bool
    @State private var swipeOffset: CGFloat = 0
    @State private var showActionLabel = false
    @State private var rowCompleted = false
    @State private var showHand = false

    var body: some View {
        VStack(spacing: 20) {
            Text(L(.walkthroughSwipeCompleteTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(L(.walkthroughSwipeCompleteSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Swipe demo area
            ZStack(alignment: .leading) {
                // Green action behind
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    if showActionLabel {
                        Text(L(.markCompleted))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .transition(.opacity)
                    }
                }
                .foregroundStyle(.white)
                .padding(.leading, 16)
                .frame(maxHeight: .infinity)
                .frame(width: max(swipeOffset, 0))
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.greenBase)
                )
                .clipped()

                // Mock job row
                MockRow {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Marco's Kitchen")
                                .font(.headline)
                            HStack(spacing: 6) {
                                Text("Apr 15, 2026")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Label {
                                    Text("Apr 28")
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                .font(.caption)
                                .foregroundStyle(Color.orangeBase)
                            }
                        }
                        Spacer()
                        Text("$703.75")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                }
                .overlay(alignment: .center) {
                    if rowCompleted {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.greenBase)
                            Text(L(.walkthroughJobCompleted))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.greenBold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .offset(x: swipeOffset)

                // Animated hand
                if showHand {
                    Image(systemName: "hand.point.right.fill")
                        .font(.title2)
                        .foregroundStyle(Color.yellowBase)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        .offset(x: swipeOffset - 10, y: 24)
                        .transition(.opacity)
                }
            }
            .frame(height: 72)
            .padding(.horizontal, 24)
        }
        .onChange(of: animationTrigger) { _, triggered in
            if triggered { runSwipeDemo() }
        }
        .onAppear {
            if animationTrigger { runSwipeDemo() }
        }
    }

    private func runSwipeDemo() {
        swipeOffset = 0
        showActionLabel = false
        rowCompleted = false
        showHand = false
        isAnimating = true

        // Show hand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.3)) { showHand = true }
        }

        // Swipe right
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.7)) {
                swipeOffset = 140
            }
        }

        // Show label
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showActionLabel = true
            }
        }

        // Release & complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                swipeOffset = 0
                showHand = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                rowCompleted = true
                showActionLabel = false
            }
            isAnimating = false
        }
    }
}

// MARK: - Page 4: Swipe to Archive

private struct SwipeArchivePage: View {
    @Binding var animationTrigger: Bool
    @Binding var isAnimating: Bool
    @State private var swipeOffset: CGFloat = 0
    @State private var showActionLabel = false
    @State private var rowArchived = false
    @State private var showHand = false
    @State private var rowHeight: CGFloat = 72

    var body: some View {
        VStack(spacing: 20) {
            Text(L(.walkthroughSwipeArchiveTitle))
                .font(.title2)
                .fontWeight(.bold)

            Text(L(.walkthroughSwipeArchiveSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Swipe demo area
            ZStack(alignment: .trailing) {
                // Orange action behind (trailing side)
                HStack(spacing: 6) {
                    if showActionLabel {
                        Text(L(.archiveJob))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .transition(.opacity)
                    }
                    Image(systemName: "archivebox.fill")
                        .font(.title3)
                }
                .foregroundStyle(.white)
                .padding(.trailing, 16)
                .frame(maxHeight: .infinity)
                .frame(width: max(-swipeOffset, 0))
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.orangeBase)
                )
                .clipped()

                // Mock completed job row
                MockRow {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.greenBase)
                            .font(.subheadline)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Marco's Kitchen")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 6) {
                                Text("Apr 15, 2026")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Label {
                                    Text("Apr 28")
                                } icon: {
                                    Image(systemName: "calendar")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("$703.75")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .offset(x: swipeOffset)

                // Animated hand
                if showHand {
                    Image(systemName: "hand.point.left.fill")
                        .font(.title2)
                        .foregroundStyle(Color.yellowBase)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        .offset(x: swipeOffset + 10, y: 24)
                        .transition(.opacity)
                }
            }
            .frame(height: rowHeight)
            .padding(.horizontal, 24)
            .clipped()

            if rowArchived {
                HStack(spacing: 6) {
                    Image(systemName: "archivebox.fill")
                        .foregroundStyle(Color.orangeBase)
                    Text(L(.walkthroughJobArchived))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.orangeBold)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: animationTrigger) { _, triggered in
            if triggered { runArchiveDemo() }
        }
        .onAppear {
            if animationTrigger { runArchiveDemo() }
        }
    }

    private func runArchiveDemo() {
        swipeOffset = 0
        showActionLabel = false
        rowArchived = false
        showHand = false
        rowHeight = 72
        isAnimating = true

        // Show hand
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.3)) { showHand = true }
        }

        // Swipe left
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.7)) {
                swipeOffset = -140
            }
        }

        // Show label
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showActionLabel = true
            }
        }

        // Release & archive
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                swipeOffset = 0
                showHand = false
                showActionLabel = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                rowHeight = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                rowArchived = true
            }
            isAnimating = false
        }
    }
}

// MARK: - Shared Components

private enum MockItemRow {
    case material(String, String, String)
    case labor(String, String, String)
}

private struct MockRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.regularMaterial)
            )
    }
}

// MARK: - Preview

#Preview {
    FeatureWalkthroughView(onComplete: {})
}
