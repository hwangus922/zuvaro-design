import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        PageTitle(text: "Profile")
                        Spacer()
                        Button { appModel.navigate(to: .settings) } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(ZuvaroTheme.textMute)
                                .frame(width: 36, height: 36)
                                .background(ZuvaroTheme.card)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                        }
                        .buttonStyle(.plain)
                    }

                    AvatarView(emoji: appModel.currentProfile?.avatarEmoji ?? "👑", size: 80)
                    VStack(spacing: 4) {
                        Text(appModel.currentProfile?.displayName ?? "Zuvaro Player")
                            .font(.system(size: 16, weight: .semibold))
                        Text(appModel.currentProfile?.handle ?? "@player")
                            .font(.system(size: 12))
                            .foregroundStyle(ZuvaroTheme.textMute)
                    }
                    if appModel.isAdmin {
                        AdminBadge()
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill").foregroundStyle(ZuvaroTheme.orange).font(.system(size: 12))
                        Text("\(appModel.currentProfile?.longestStreak ?? 0) day streak · on fire")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ZuvaroTheme.orange.opacity(0.12))
                    .clipShape(Capsule())

                    statsCard
                    accountSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
        .alert("Delete account?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task { await appModel.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your profile, photos, messages, and all associated data. This cannot be undone.")
        }
    }

    private var statsCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL POINTS").font(.system(size: 9, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                    WarmGradientText(text: "\(appModel.totalPoints)", size: 44)
                    Text("pts").font(.system(size: 18, weight: .bold)).foregroundStyle(ZuvaroTheme.textMute)
                }
                Spacer()
            }
            .padding(18)

            ForEach([
                ("Wins", "\(appModel.currentProfile?.wins ?? 0)"),
                ("Longest Streak", "\(appModel.currentProfile?.longestStreak ?? 0)"),
                ("Total Points", "\(appModel.totalPoints)"),
                ("Challenges Completed", "\(appModel.currentProfile?.challengesCompleted ?? 0)")
            ], id: \.0) { label, value in
                Divider()
                HStack {
                    Text(label).font(.system(size: 16))
                    Spacer()
                    Text(value).font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
        }
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }

    private var accountSection: some View {
        VStack(spacing: 0) {
            if appModel.isAdmin {
                accountRow(
                    "Review proofs",
                    badge: appModel.adminPendingCount > 0 ? "\(appModel.adminPendingCount) pending" : nil
                ) { appModel.navigate(to: .adminReview) }
                Divider()
            }
            accountRow("Change username") { appModel.navigate(to: .setUsername) }
            Divider()
            accountRow(
                "My submissions",
                badge: appModel.pendingSubmissionsCount > 0 ? "\(appModel.pendingSubmissionsCount) pending" : nil
            ) { appModel.navigate(to: .submissions) }
            Divider()
            accountRow("Invite friends") { appModel.navigate(to: .invite) }
            Divider()
            accountRow("Log out") { Task { await appModel.signOut() } }
            Divider()
            accountRow("Delete Account", destructive: true) { showDeleteConfirmation = true }
        }
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }

    private func accountRow(_ title: String, badge: String? = nil, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(destructive ? ZuvaroTheme.orange : ZuvaroTheme.text)
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(ZuvaroTheme.orange.opacity(0.08))
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(destructive ? ZuvaroTheme.orange : ZuvaroTheme.textMute)
                }
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}
