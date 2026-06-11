import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var filter = "All"

    private let filters = ["All", "Sponsored", "Big pts", "Quick"]

    private var challenges: [Challenge] {
        switch filter {
        case "Sponsored": return appModel.challenges.filter(\.isSponsored)
        case "Big pts": return appModel.challenges.filter { ($0.points ?? 0) >= 20 }
        case "Quick": return appModel.challenges.filter { $0.minutes <= 15 }
        default: return appModel.challenges
        }
    }

    private var goalPoints: Int {
        max(appModel.questTotal * 68, 100)
    }

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        PageTitle(text: "Missions")
                        Spacer()
                        HStack(spacing: 4) {
                            Text("🔥")
                            Text("\(appModel.currentProfile?.longestStreak ?? 0)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(ZuvaroTheme.orange)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(ZuvaroTheme.orange.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    TodayPointsCard(
                        points: appModel.totalPoints,
                        goalPoints: goalPoints,
                        questDone: appModel.questDone,
                        questTotal: appModel.questTotal
                    ) {
                        appModel.navigate(to: .questChain)
                    }

                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { name in
                            FilterChip(title: name, isSelected: filter == name) { filter = name }
                        }
                    }

                    ForEach(challenges) { challenge in
                        Button {
                            appModel.openChallenge(challenge)
                        } label: {
                            ChallengeCardView(challenge: challenge)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
    }
}

struct QuestChainView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Quest Chain", onBack: { appModel.pop() }, useGradientTitle: true)
                    TodayPointsCard(
                        points: appModel.totalPoints,
                        goalPoints: max(appModel.questTotal * 68, 100),
                        questDone: appModel.questDone,
                        questTotal: appModel.questTotal
                    )
                    Text("TODAY'S DARES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                    ForEach(appModel.challenges) { c in
                        Button { appModel.openChallenge(c) } label: {
                            ChallengeCardView(challenge: c)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
        }
        .navigationBarHidden(true)
    }
}

struct SearchView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var query = ""

    private var results: [Challenge] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return appModel.challenges }
        return appModel.challenges.filter {
            $0.text.lowercased().contains(q) || $0.hook.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScreenHeader(title: "Search", onBack: { appModel.pop() }, useGradientTitle: true)
            TextField("Try phone, run, joke…", text: $query)
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            ForEach(results) { c in
                Button { appModel.openChallenge(c) } label: {
                    ChallengeCardView(challenge: c)
                }.buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(24)
        .background(ZuvaroTheme.screenBg)
        .navigationBarHidden(true)
    }
}
