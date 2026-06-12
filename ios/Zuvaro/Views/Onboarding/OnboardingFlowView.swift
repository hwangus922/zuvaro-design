import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("zuvaro_age_confirmed") private var ageConfirmed = false
    @State private var step = 0
    @State private var emailIsSignUp = true

    var body: some View {
        Group {
            if step == 3 {
                SignInView(
                    onBack: { withAnimation { step = 1 } },
                    onEmailSignIn: { withAnimation { emailIsSignUp = false; step = 4 } },
                    onSignUp: { withAnimation { step = 2 } }
                )
            } else if step == 4 {
                EmailAuthView(
                    isSignUp: emailIsSignUp,
                    onBack: { withAnimation { step = emailIsSignUp ? 2 : 3 } },
                    onToggleMode: { emailIsSignUp.toggle() }
                )
            } else {
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
                            SignUpProvidersView(
                                onBack: { withAnimation { step = 1 } },
                                onEmailSignUp: { withAnimation { emailIsSignUp = true; step = 4 } },
                                onSignIn: { withAnimation { step = 3 } }
                            )
                        }

                        Spacer()
                    }
                    .padding(24)
                }
            }
        }
        .onAppear {
            appModel.trackScreen("onboarding_splash")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if step == 0 { withAnimation { step = 1 } }
            }
        }
        .onChange(of: step) { _, newStep in
            switch newStep {
            case 1: appModel.trackScreen("onboarding_welcome")
            case 2: appModel.trackScreen("onboarding_sign_up")
            case 3: appModel.trackScreen("onboarding_sign_in")
            case 4: appModel.trackScreen("onboarding_email_auth")
            default: break
            }
        }
    }

    private var splashContent: some View {
        VStack(spacing: 16) {
            ZuvaroLogo(style: .wordmark, size: .large)
            Text("Sponsored dares. Real payouts.")
                .font(.system(size: 16))
                .foregroundStyle(ZuvaroTheme.textMute)
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 20) {
            ZuvaroLogo(style: .wordmark, size: .medium)
            Text("Welcome to Zuvaro")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(ZuvaroTheme.text)
            Text("Brands sponsor missions. You complete dares, earn points, and fight for a spot in the top 5 to split the weekly prize pool.")
                .font(.system(size: 15))
                .foregroundStyle(ZuvaroTheme.textMute)
                .multilineTextAlignment(.center)
            AgeConfirmationGate(confirmed: $ageConfirmed)
                .onChange(of: ageConfirmed) { _, confirmed in
                    if confirmed { appModel.trackAgeConfirmed() }
                }
            PrimaryButton(title: "Continue", enabled: ageConfirmed) { withAnimation { step = 2 } }
            SecondaryTextButton(title: "Sign in") { withAnimation { step = 3 } }
        }
    }
}
