import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var filter = "Recommended"

    private var challenges: [Challenge] {
        switch filter {
        case "Rewarding": return MockData.challenges.filter { $0.points != nil }
        case "Short": return MockData.challenges.filter { $0.minutes <= 15 }
        default: return MockData.challenges
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    QuestChainCard(questDone: appModel.questDone, questTotal: appModel.questTotal) {
                        appModel.navigate(to: .questChain)
                    }
                    filterRow
                    ForEach(challenges) { challenge in
                        Button {
                            appModel.openChallenge(challenge)
                        } label: {
                            ChallengeCardView(challenge: challenge)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            AvatarView()
            iconButton("message.fill") { appModel.navigate(to: .chat) }
            Spacer()
            iconButton("bell.fill", badge: true) { appModel.navigate(to: .notifications) }
            iconButton("chart.line.uptrend.xyaxis") {}
            Text("45")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
            Image(systemName: "bolt.fill")
                .foregroundStyle(ZuvaroTheme.orange)
            WarmGradientText(text: "\(appModel.totalPoints)pts", size: 13, weight: .bold)
        }
        .padding(.top, 8)
    }

    private func iconButton(_ name: String, badge: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.text)
                    .frame(width: 32, height: 32)
                    .background(ZuvaroTheme.card)
                    .clipShape(Circle())
                if badge {
                    Circle().fill(ZuvaroTheme.pink).frame(width: 8, height: 8).offset(x: 2, y: -2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var filterRow: some View {
        HStack(spacing: 8) {
            ForEach(["Recommended", "Rewarding", "Short"], id: \.self) { name in
                FilterChip(title: name, isSelected: filter == name) { filter = name }
            }
            Spacer()
            Button { appModel.navigate(to: .search) } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.textMute)
                    .frame(width: 24, height: 24)
                    .background(ZuvaroTheme.card)
                    .clipShape(Circle())
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
                    ScreenHeader(title: "Quest Chain", onBack: { appModel.pop() })
                    QuestChainCard(questDone: appModel.questDone, questTotal: appModel.questTotal)
                    Text("TODAY'S DARES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                    ForEach(MockData.challenges) { c in
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
        guard !q.isEmpty else { return MockData.challenges }
        return MockData.challenges.filter {
            $0.text.lowercased().contains(q) || $0.hook.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScreenHeader(title: "Search dares", onBack: { appModel.pop() })
            TextField("Try phone, run, joke…", text: $query)
                .padding(14)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            ForEach(results) { c in
                Button { appModel.openChallenge(c) } label: {
                    ChallengeCardView(challenge: c)
                }.buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(24)
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}
