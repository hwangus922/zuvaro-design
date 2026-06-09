import SwiftUI

struct GroupChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var draft = ""
    @State private var reportTarget: ChatMessage?
    @State private var reportDetails = ""
    @State private var isSubmittingReport = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: appModel.primaryGroup?.name ?? "Chaos Crew", onBack: { appModel.pop() })
                .padding(.horizontal, 24)
                .padding(.top, 8)

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(appModel.chatMessages) { msg in
                        chatBubble(msg)
                    }
                }
                .padding(24)
            }

            HStack(spacing: 8) {
                Button { appModel.navigate(to: .createDare) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.inkOnWarm)
                        .frame(width: 44, height: 44)
                        .background(ZuvaroTheme.warmGradient)
                        .clipShape(Circle())
                }
                TextField("Send a message…", text: $draft)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(ZuvaroTheme.card)
                    .clipShape(Capsule())
                    .onSubmit { sendMessage() }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .sheet(item: $reportTarget) { msg in
            ReportUserSheet(
                userName: msg.author,
                details: $reportDetails,
                isSubmitting: isSubmittingReport,
                errorMessage: appModel.supportError,
                onCancel: { reportTarget = nil; reportDetails = "" },
                onSubmit: {
                    isSubmittingReport = true
                    Task {
                        let didSend = await appModel.reportUser(
                            reportedUserId: msg.userId,
                            messageId: msg.id,
                            details: reportDetails
                        )
                        await MainActor.run {
                            isSubmittingReport = false
                            if didSend {
                                reportTarget = nil
                                reportDetails = ""
                            }
                        }
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func sendMessage() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty,
              let groupId = appModel.primaryGroup?.id,
              let userId = appModel.currentProfile?.id else { return }
        draft = ""
        Task {
            try? await ZuvaroServices.shared.chat.sendMessage(groupId: groupId, userId: userId, text: text)
            await appModel.refreshAll()
        }
    }

    @ViewBuilder
    private func chatBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isMe { Spacer(minLength: 40) }
            if !msg.isMe {
                Text(msg.emoji).font(.title3)
            }
            if msg.isDare {
                dareBubble(msg)
            } else {
                messageBubble(msg)
            }
            if !msg.isMe { Spacer(minLength: 40) }
        }
    }

    @ViewBuilder
    private func dareBubble(_ msg: ChatMessage) -> some View {
        Button {
            if let id = msg.dareChallengeId, let challenge = appModel.challenge(for: id) {
                appModel.openChallenge(challenge)
            } else if let customId = msg.dareCustomChallengeId {
                let dareText = msg.text.replacingOccurrences(
                    of: #" \(\+\d+pts\)$"#,
                    with: "",
                    options: .regularExpression
                )
                appModel.openChallenge(
                    Challenge(
                        id: customId,
                        time: "custom",
                        text: dareText,
                        points: msg.darePoints,
                        hook: "Custom dare from your crew",
                        minutes: 0,
                        rules: "Complete the dare and submit photo proof.",
                        isCustomChallenge: true
                    )
                )
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text("NEW DARE").font(.system(size: 9, weight: .bold)).opacity(0.7)
                Text(msg.text).font(.system(size: 15, weight: .bold))
                Text("+\(msg.darePoints ?? 0)pts · tap to accept")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(ZuvaroTheme.inkOnWarm)
            .padding(14)
            .background(ZuvaroTheme.cardWarmGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .modifier(MessageSafetyMenu(msg: msg, onReport: { reportTarget = msg }))
    }

    @ViewBuilder
    private func messageBubble(_ msg: ChatMessage) -> some View {
        Text(msg.text)
            .font(.system(size: 14))
            .foregroundStyle(msg.isMe ? ZuvaroTheme.inkOnWarm : ZuvaroTheme.text)
            .padding(12)
            .background {
                if msg.isMe {
                    ZuvaroTheme.warmGradient
                } else {
                    ZuvaroTheme.card
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .modifier(MessageSafetyMenu(msg: msg, onReport: { reportTarget = msg }))
    }
}

private struct MessageSafetyMenu: ViewModifier {
    @EnvironmentObject private var appModel: AppModel
    let msg: ChatMessage
    var onReport: () -> Void

    func body(content: Content) -> some View {
        if msg.isMe {
            content
        } else {
            content.contextMenu {
                Button("Block user", role: .destructive) {
                    Task { await appModel.blockUser(msg.userId) }
                }
                Button("Report user", role: .destructive) {
                    onReport()
                }
            }
        }
    }
}

struct CreateDareView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var text = ""
    @State private var points = 20
    @State private var isPosting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Create dare", onBack: { appModel.pop() })
                TextField("Dare text", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Text("Points: \(points)")
                Slider(value: Binding(get: { Double(points) }, set: { points = Int($0) }), in: 0...60, step: 10)
                PrimaryButton(title: isPosting ? "Posting..." : "Post to group chat", enabled: !isPosting && text.trimmingCharacters(in: .whitespacesAndNewlines).count > 3) {
                    isPosting = true
                    let message = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    Task {
                        await appModel.postCustomDare(text: message, points: points)
                        await MainActor.run {
                            isPosting = false
                            appModel.pop()
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct NotificationsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ScreenHeader(title: "Notifications", onBack: { appModel.pop() })
                ForEach(appModel.notifications) { n in
                    Button {
                        switch n.kind {
                        case .dare: appModel.navigate(to: .chat)
                        case .proof: appModel.navigate(to: .submissions)
                        default: break
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Circle().fill(ZuvaroTheme.pink).frame(width: 8, height: 8).opacity(n.unread ? 1 : 0)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(n.title).font(.system(size: 14, weight: .semibold))
                                Text(n.body).font(.system(size: 13)).foregroundStyle(ZuvaroTheme.textMute)
                                Text(n.time).font(.system(size: 11)).foregroundStyle(ZuvaroTheme.textDim)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(n.unread ? ZuvaroTheme.pink.opacity(0.05) : ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct InviteFriendsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var copied = false

    private var referralSubtitle: String {
        if appModel.referralBonusEarned {
            return "You unlocked +50pts for inviting 5 friends. Keep growing your crew."
        }
        let remaining = appModel.currentProfile?.referralsUntilBonus ?? 5
        return "Invite 5 friends to unlock +50pts. \(remaining) more to go."
    }

    private var referralProgressCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(appModel.referralProgress)/5 friends joined")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                if appModel.referralBonusEarned {
                    Text("+50pts earned")
                        .font(.system(size: 12, weight: .bold))
                } else {
                    Text("+50pts reward")
                        .font(.system(size: 12, weight: .bold))
                        .opacity(0.8)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.18))
                    Capsule()
                        .fill(Color.black)
                        .frame(width: geo.size.width * CGFloat(appModel.referralProgress) / 5.0)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(Color.black.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScreenHeader(title: "Invite friends", onBack: { appModel.pop() })
                VStack(spacing: 12) {
                    Text("🎉").font(.largeTitle)
                    Text("Bring your crew to \(appModel.primaryGroup?.name ?? "Chaos Crew")")
                        .font(.system(size: 16, weight: .bold))
                    Text(referralSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .multilineTextAlignment(.center)

                    referralProgressCard
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(ZuvaroTheme.cardWarmGradient)
                .foregroundStyle(ZuvaroTheme.inkOnWarm)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                HStack {
                    Text("zuvaro.app/join/\(appModel.inviteCode)")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    Spacer()
                    Button(copied ? "Copied!" : "Copy") {
                        UIPasteboard.general.string = "zuvaro.app/join/\(appModel.inviteCode)"
                        copied = true
                    }
                    .font(.system(size: 13, weight: .bold))
                }
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                ShareLink(
                    item: URL(string: "https://zuvaro.app/join/\(appModel.inviteCode)")!,
                    subject: Text("Join my Zuvaro crew"),
                    message: Text("Hop in my group with this invite code: \(appModel.inviteCode)")
                ) {
                    Text("Share via Messages")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.inkOnWarm)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(ZuvaroTheme.warmGradient)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}
