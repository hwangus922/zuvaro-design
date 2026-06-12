import SwiftUI

struct UsernameOnboardingView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var username = ""
    @State private var isSaving = false
    @State private var availabilityMessage: String?
    @State private var isCheckingAvailability = false

    private var normalizedUsername: String {
        UsernameValidator.normalize(username)
    }

    private var validationMessage: String? {
        UsernameValidator.validationMessage(for: username)
    }

    private var canContinue: Bool {
        !isSaving && validationMessage == nil && !normalizedUsername.isEmpty
    }

    var body: some View {
        ZStack {
            ZuvaroTheme.screenBg.ignoresSafeArea()
            AuraBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZuvaroLogo(style: .wordmark, size: .medium)

                    Text("Pick a username")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.text)

                    Text("This is how friends find you on leaderboards and in your crew.")
                        .font(.system(size: 15))
                        .foregroundStyle(ZuvaroTheme.textMute)

                    UsernameField(text: $username, onChange: {
                        availabilityMessage = nil
                    })

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.orange)
                    } else if let availabilityMessage {
                        Text(availabilityMessage)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                availabilityMessage.contains("available")
                                    ? ZuvaroTheme.success
                                    : ZuvaroTheme.orange
                            )
                    }

                    if validationMessage == nil, !normalizedUsername.isEmpty {
                        SecondaryTextButton(title: isCheckingAvailability ? "Checking..." : "Check availability") {
                            Task { await checkAvailability() }
                        }
                        .disabled(isCheckingAvailability)
                    }

                    if let error = appModel.usernameError {
                        Text(error)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.orange)
                    }

                    PrimaryButton(title: isSaving ? "Saving..." : "Continue", enabled: canContinue) {
                        Task { await saveUsername() }
                    }

                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
        }
    }

    private func checkAvailability() async {
        isCheckingAvailability = true
        defer { isCheckingAvailability = false }
        let available = await appModel.checkUsernameAvailability(username)
        availabilityMessage = available
            ? "@\(normalizedUsername) is available."
            : "@\(normalizedUsername) is already taken."
    }

    private func saveUsername() async {
        isSaving = true
        defer { isSaving = false }
        let didSave = await appModel.setUsername(username)
        if didSave {
            availabilityMessage = nil
        }
    }
}

struct SetUsernameView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var username = ""
    @State private var isSaving = false
    @State private var availabilityMessage: String?
    @State private var isCheckingAvailability = false

    private var normalizedUsername: String {
        UsernameValidator.normalize(username)
    }

    private var validationMessage: String? {
        UsernameValidator.validationMessage(for: username)
    }

    private var canSave: Bool {
        !isSaving && validationMessage == nil && !normalizedUsername.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Change username", onBack: { appModel.pop() })

                Text("Your username shows on leaderboards and in your crew.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.textMute)

                UsernameField(text: $username, onChange: {
                    availabilityMessage = nil
                })

                if let validationMessage {
                    Text(validationMessage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ZuvaroTheme.orange)
                } else if let availabilityMessage {
                    Text(availabilityMessage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            availabilityMessage.contains("available")
                                ? ZuvaroTheme.success
                                : ZuvaroTheme.orange
                        )
                }

                if validationMessage == nil, !normalizedUsername.isEmpty {
                    SecondaryTextButton(title: isCheckingAvailability ? "Checking..." : "Check availability") {
                        Task { await checkAvailability() }
                    }
                    .disabled(isCheckingAvailability)
                }

                if let error = appModel.usernameError {
                    Text(error)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ZuvaroTheme.orange)
                }

                PrimaryButton(title: isSaving ? "Saving..." : "Save username", enabled: canSave) {
                    Task { await saveUsername() }
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.screenBg)
        .navigationBarHidden(true)
        .onAppear {
            guard let profile = appModel.currentProfile, username.isEmpty else { return }
            username = profile.handle.hasPrefix("@") ? String(profile.handle.dropFirst()) : profile.handle
        }
    }

    private func checkAvailability() async {
        isCheckingAvailability = true
        defer { isCheckingAvailability = false }
        let available = await appModel.checkUsernameAvailability(username)
        availabilityMessage = available
            ? "@\(normalizedUsername) is available."
            : "@\(normalizedUsername) is already taken."
    }

    private func saveUsername() async {
        isSaving = true
        defer { isSaving = false }
        let didSave = await appModel.setUsername(username)
        if didSave {
            appModel.pop()
        }
    }
}

struct UsernameField: View {
    @Binding var text: String
    var onChange: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Text("@")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(ZuvaroTheme.textMute)
            TextField("username", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ZuvaroTheme.text)
                .onChange(of: text) { _, newValue in
                    let filtered = UsernameValidator.normalize(newValue)
                    if filtered != newValue {
                        text = filtered
                    }
                    onChange?()
                }
        }
        .padding(14)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}
