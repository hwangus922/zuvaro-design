import AuthenticationServices
import SwiftUI

struct SignInWithAppleButtonView: View {
    var onRequest: (ASAuthorizationAppleIDRequest) -> Void
    var onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        SignInWithAppleButton(.continue) { request in
            onRequest(request)
        } onCompletion: { result in
            onCompletion(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 48)
        .clipShape(Capsule())
    }
}

struct SignInView: View {
    @EnvironmentObject private var appModel: AppModel
    var onBack: (() -> Void)?
    var onEmailSignIn: () -> Void
    var onSignUp: () -> Void

    var body: some View {
        ZStack {
            ZuvaroTheme.bg.ignoresSafeArea()
            AuraBackground()

            VStack(spacing: 0) {
                HStack {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(ZuvaroTheme.text)
                                .frame(width: 36, height: 36)
                                .background(ZuvaroTheme.card)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 20) {
                    ZuvaroLogo(style: .wordmark, size: .medium)
                    Text("Sign in")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.text)
                    Text("Pick up where you left off.")
                        .font(.system(size: 15))
                        .foregroundStyle(ZuvaroTheme.textMute)

                    if let message = appModel.authError {
                        Text(message)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.orange)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(ZuvaroTheme.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    SignInWithAppleButtonView(
                        onRequest: { request in appModel.prepareAppleSignIn(request) },
                        onCompletion: { result in
                            Task { await appModel.handleAppleSignIn(result) }
                        }
                    )

                    PrimaryButton(title: "Continue with email", enabled: !appModel.isAuthenticating) {
                        onEmailSignIn()
                    }

                    SecondaryTextButton(title: "New here? Sign up") { onSignUp() }

                    TermsPrivacyFooter()
                }
                .padding(24)

                Spacer()
            }
        }
    }
}

struct EmailAuthView: View {
    @EnvironmentObject private var appModel: AppModel
    let isSignUp: Bool
    var onBack: () -> Void
    var onToggleMode: () -> Void

    @AppStorage("zuvaro_age_confirmed") private var ageConfirmed = false
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !appModel.isAuthenticating && (!isSignUp || ageConfirmed)
    }

    var body: some View {
        ZStack {
            ZuvaroTheme.bg.ignoresSafeArea()
            AuraBackground()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.text)
                            .frame(width: 36, height: 36)
                            .background(ZuvaroTheme.card)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ZuvaroLogo(style: .wordmark, size: .medium)
                        Text(isSignUp ? "Create account" : "Sign in")
                            .font(.system(size: 28, weight: .bold))
                        Text(isSignUp ? "Email in, dignity optional." : "Same email you used last time.")
                            .font(.system(size: 14))
                            .foregroundStyle(ZuvaroTheme.textMute)

                        VStack(spacing: 12) {
                            TextField("you@example.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(14)
                                .background(ZuvaroTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            SecureField("Password", text: $password)
                                .textContentType(isSignUp ? .newPassword : .password)
                                .padding(14)
                                .background(ZuvaroTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if isSignUp {
                            AgeConfirmationGate(confirmed: $ageConfirmed)
                        }

                        if let message = appModel.authError {
                            Text(message)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(ZuvaroTheme.orange)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(ZuvaroTheme.orange.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        PrimaryButton(
                            title: isSignUp ? "Create account" : "Sign in",
                            enabled: canSubmit
                        ) {
                            Task {
                                if isSignUp {
                                    await appModel.signUp(email: email, password: password)
                                } else {
                                    await appModel.signIn(email: email, password: password)
                                }
                            }
                        }

                        SecondaryTextButton(
                            title: isSignUp ? "Already have an account? Sign in" : "New here? Create account"
                        ) { onToggleMode() }

                        if isSignUp {
                            TermsPrivacyFooter()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

struct SignUpProvidersView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("zuvaro_age_confirmed") private var ageConfirmed = false
    var onBack: () -> Void
    var onEmailSignUp: () -> Void
    var onSignIn: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ZuvaroTheme.text)
                        .frame(width: 36, height: 36)
                        .background(ZuvaroTheme.card)
                        .clipShape(Circle())
                }
                Spacer()
            }

            ZuvaroLogo(style: .wordmark, size: .medium)

            Text("Create account")
                .font(.system(size: 24, weight: .bold))

            if let message = appModel.authError {
                Text(message)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.orange)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(ZuvaroTheme.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            AgeConfirmationGate(confirmed: $ageConfirmed)

            SignInWithAppleButtonView(
                onRequest: { request in appModel.prepareAppleSignIn(request) },
                onCompletion: { result in
                    Task { await appModel.handleAppleSignIn(result) }
                }
            )
            .disabled(!ageConfirmed || appModel.isAuthenticating)
            .opacity(ageConfirmed ? 1 : 0.5)

            PrimaryButton(title: "Use email instead", enabled: ageConfirmed && !appModel.isAuthenticating) {
                onEmailSignUp()
            }

            SecondaryTextButton(title: "Already have an account? Sign in") { onSignIn() }

            TermsPrivacyFooter()
        }
    }
}
