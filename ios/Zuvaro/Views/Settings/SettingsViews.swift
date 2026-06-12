import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Settings", onBack: { appModel.pop() })

                if appModel.isAdmin {
                    AdminBadge()
                }

                Text("NOTIFICATIONS").font(.system(size: 10, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                Button("View all notifications") { appModel.navigate(to: .notifications) }
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(ZuvaroTheme.text)

                if appModel.isAdmin {
                    Text("ADMIN").font(.system(size: 10, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                    settingsRow(
                        "Review proofs",
                        badge: appModel.adminPendingCount > 0 ? "\(appModel.adminPendingCount) pending" : nil
                    ) {
                        appModel.navigate(to: .adminReview)
                    }
                }

                Text("ACCOUNT").font(.system(size: 10, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                settingsRow("Edit profile") { appModel.navigate(to: .editProfile) }
                settingsRow("Change username") { appModel.navigate(to: .setUsername) }
                settingsRow("Privacy preferences") { appModel.navigate(to: .privacy) }
                settingsRow("Blocked users") { appModel.navigate(to: .blockedUsers) }
                settingsRow("Help & support") { appModel.navigate(to: .help) }

                LegalLinksSection()
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }

    private func settingsRow(_ title: String, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.system(size: 15))
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ZuvaroTheme.orange.opacity(0.12))
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right").foregroundStyle(ZuvaroTheme.textMute)
            }
            .padding(14)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var name = ""
    @State private var handle = ""
    @State private var isSaving = false

    private var canSave: Bool {
        !isSaving
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && UsernameValidator.validationMessage(for: handle) == nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(title: "Edit profile", onBack: { appModel.pop() })
                AvatarView(size: 80)
                TextField("Display name", text: $name).textFieldStyle(.roundedBorder)
                UsernameField(text: $handle)
                if let validationMessage = UsernameValidator.validationMessage(for: handle) {
                    Text(validationMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
                if let profileSaveError = appModel.profileSaveError {
                    Text(profileSaveError)
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                }
                PrimaryButton(title: isSaving ? "Saving..." : "Save changes", enabled: canSave) {
                    isSaving = true
                    Task {
                        let didSave = await appModel.saveProfile(displayName: name, handle: handle)
                        await MainActor.run {
                            isSaving = false
                            if didSave { appModel.pop() }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .onAppear {
            guard let profile = appModel.currentProfile else { return }
            if name.isEmpty { name = profile.displayName }
            if handle.isEmpty {
                handle = profile.handle.hasPrefix("@") ? String(profile.handle.dropFirst()) : profile.handle
            }
        }
    }
}

struct PrivacyView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("zuvaro_public_profile") private var publicProfile = true
    @AppStorage("zuvaro_show_on_leaderboard") private var showOnBoard = true
    @AppStorage(AnalyticsPreferences.enabledKey) private var analyticsEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "Privacy preferences", onBack: { appModel.pop() })
                Toggle("Public profile", isOn: $publicProfile).padding(14).background(ZuvaroTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
                Toggle("Show on leaderboards", isOn: $showOnBoard).padding(14).background(ZuvaroTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Share usage analytics", isOn: $analyticsEnabled)
                    Text("Helps us improve Zuvaro. We collect usage events such as screens viewed and dares started. Events may be linked to your account ID but never include dare text, photos, or chat messages. You can turn this off anytime.")
                        .font(.system(size: 12))
                        .foregroundStyle(ZuvaroTheme.textMute)
                }
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onChange(of: analyticsEnabled) { _, enabled in
                    appModel.trackAnalyticsPreference(enabled: enabled)
                }

                LegalLinksSection()
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct BlockedUsersView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Blocked users", onBack: { appModel.pop() })
                if appModel.blockedUsers.isEmpty {
                    Text("You have not blocked anyone yet.")
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                ForEach(appModel.blockedUsers) { blockedUser in
                    HStack {
                        Text(blockedUser.blockedProfile?.displayName ?? "Unknown user")
                        Spacer()
                        Button("Unblock") {
                            Task { await appModel.unblockUser(blockedUser.blockedId) }
                        }
                        .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct HelpSupportView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.openURL) private var openURL
    @State private var reportText = ""
    @State private var isSubmitting = false
    @State private var reportSent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Help & support", onBack: { appModel.pop() })
                Text("How do I earn points?").font(.system(size: 14, weight: .semibold))
                Text("Complete dares and submit photo proof. Points credit after moderator approval.")
                    .font(.system(size: 13)).foregroundStyle(ZuvaroTheme.textMute)
                Text("Report an issue")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.top, 8)
                TextField("Tell us what happened...", text: $reportText, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                if let supportError = appModel.supportError {
                    Text(supportError)
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                }
                if reportSent {
                    Text("Thanks, your report was sent.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.green)
                }
                PrimaryButton(title: isSubmitting ? "Sending..." : "Send report", enabled: !isSubmitting && reportText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10) {
                    isSubmitting = true
                    Task {
                        let didSend = await appModel.reportSupportIssue(reportText)
                        await MainActor.run {
                            isSubmitting = false
                            reportSent = didSend
                            if didSend { reportText = "" }
                        }
                    }
                }
                PrimaryButton(title: "Contact support") {
                    guard let emailURL = URL(string: "mailto:\(AppLegal.supportEmail)") else { return }
                    openURL(emailURL)
                }
                Text(AppLegal.supportEmail).font(.system(size: 12)).foregroundStyle(ZuvaroTheme.textMute).frame(maxWidth: .infinity)

                LegalLinksSection()
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}
