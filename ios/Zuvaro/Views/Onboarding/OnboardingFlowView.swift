import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var step = 0

    var body: some View {
        ZStack {
            ZuvaroTheme.bg.ignoresSafeArea()
            AuraBackground()

            VStack(spacing: 24) {
                Spacer()

                if step == 0 {
                    splashContent
                } else if step == 1 {
                    welcomeContent
                } else {
                    signupContent
                }

                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if step == 0 { withAnimation { step = 1 } }
            }
        }
    }

    private var splashContent: some View {
        VStack(spacing: 16) {
            WarmGradientText(text: "zuvaro", size: 42, weight: .bold)
            Text("Daily dares. Real chaos.")
                .font(.system(size: 16))
                .foregroundStyle(ZuvaroTheme.textMute)
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 20) {
            WarmGradientText(text: "Welcome to Zuvaro", size: 28, weight: .bold)
            Text("Daily dares from the group chat. Climb the board. Get clout, lose dignity, repeat.")
                .font(.system(size: 15))
                .foregroundStyle(ZuvaroTheme.textMute)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Continue") { withAnimation { step = 2 } }
            SecondaryTextButton(title: "Sign in") { appModel.completeOnboarding() }
        }
    }

    private var signupContent: some View {
        VStack(spacing: 16) {
            Text("Create account")
                .font(.system(size: 24, weight: .bold))
            PrimaryButton(title: "Continue with Apple") { appModel.completeOnboarding() }
            PrimaryButton(title: "Continue with Google") { appModel.completeOnboarding() }
            SecondaryTextButton(title: "Use email instead") { appModel.completeOnboarding() }
        }
    }
}
