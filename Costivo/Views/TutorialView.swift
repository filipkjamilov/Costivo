import SwiftUI

struct TutorialSlide {
    let animation: AppAnimation
    let text: String
}

struct TutorialView: View {
    @State private var currentSlide = 0
    @State private var movieFinished = false
    @State private var textVisible = false

    var onComplete: () -> Void

    private let slides: [TutorialSlide] = [
        TutorialSlide(animation: .builders, text: L(.tutorialSlide1)),
        TutorialSlide(animation: .usingMobilePhone, text: L(.tutorialSlide2)),
        TutorialSlide(animation: .paymentHero, text: L(.tutorialSlide3)),
    ]

    private let slideDuration: Double = 4.0

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        if index == currentSlide {
                            AnimationView(slide.animation, loops: true)
                                .frame(height: 280)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                }
                .allowsHitTesting(false)

                if textVisible {
                    Text(slides[currentSlide].text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                }

                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.yellowBase : Color.greyLight)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)

                Spacer()
                Spacer()
                    .frame(height: 90)
            }
            .allowsHitTesting(false)

            // Button overlaid on top of everything so Lottie can't steal touches
            if movieFinished {
                VStack {
                    Spacer()

                    Button {
                        onComplete()
                    } label: {
                        Text(L(.tutorialGetStarted))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.yellowBase, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startMovie()
        }
    }

    private func startMovie() {
        withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
            textVisible = true
        }

        for index in 1..<slides.count {
            let delay = slideDuration * Double(index)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 0.1)) {
                    textVisible = false
                }

                withAnimation(.easeInOut(duration: 0.5).delay(0.15)) {
                    currentSlide = index
                }

                withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                    textVisible = true
                }
            }
        }

        let totalDuration = slideDuration * Double(slides.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation(.spring(duration: 0.6)) {
                movieFinished = true
            }
        }
    }
}

#Preview {
    TutorialView(onComplete: {})
}
