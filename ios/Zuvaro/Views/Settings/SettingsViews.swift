import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var daily = true
    @State private var proof = true
    @State private var board = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Settings", onBack: { appModel.pop() })

                Text("NOTIFICATIONS").font(.system(size: 10, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                toggleRow("Daily dare reminders", isOn: $daily)
                toggleRow("Proof approved", isOn: $proof)
                toggleRow("Leaderboard updates", isOn: $board)
                Button("View all notifications") { appModel.navigate(to: .notifications) }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.pink)

                Text("ACCOUNT").font(.system(size: 10, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                settingsRow("Edit profile") { appModel.navigate(to: .editProfile) }
                settingsRow("Privacy") { appModel.navigate(to: .privacy) }
                settingsRow("Blocked users") { appModel.navigate(to: .blockedUsers) }
                settingsRow("Help & support") { appModel.navigate(to: .help) }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .padding(14)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func settingsRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.system(size: 15))
                Spacer()
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
    @State private var name = "John Winner"
    @State private var handle = "@IloveMyGTA6too"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(title: "Edit profile", onBack: { appModel.pop() })
                AvatarView(size: 80)
                TextField("Display name", text: $name).textFieldStyle(.roundedBorder)
                TextField("Username", text: $handle).textFieldStyle(.roundedBorder)
                PrimaryButton(title: "Save changes") { appModel.pop() }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct PrivacyView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var publicProfile = true
    @State private var showOnBoard = true

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "Privacy", onBack: { appModel.pop() })
                Toggle("Public profile", isOn: $publicProfile).padding(14).background(ZuvaroTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
                Toggle("Show on leaderboards", isOn: $showOnBoard).padding(14).background(ZuvaroTheme.card).clipShape(RoundedRectangle(cornerRadius: 16))
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
                ForEach(["Spam Bot 3000", "Toxic Tim"], id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Button("Unblock") {}.font(.system(size: 13, weight: .semibold))
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Help & support", onBack: { appModel.pop() })
                Text("How do I earn points?").font(.system(size: 14, weight: .semibold))
                Text("Complete dares and submit photo proof. Points credit after moderator approval.")
                    .font(.system(size: 13)).foregroundStyle(ZuvaroTheme.textMute)
                PrimaryButton(title: "Contact support") {}
                Text("support@zuvaro.app").font(.system(size: 12)).foregroundStyle(ZuvaroTheme.textMute).frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}
