import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var tab = 0
    private let tabs = ["Friends", "Club", "Global"]

    private var rows: [LeaderboardEntry] {
        let base = appModel.leaderboard
        switch tab {
        case 1: return base.enumerated().map { i, e in
            LeaderboardEntry(id: e.id, rank: i + 1, name: e.name, handle: e.handle, points: e.points - 40 + i * 7, emoji: e.emoji, isMe: e.isMe)
        }
        case 2: return base.enumerated().map { i, e in
            LeaderboardEntry(id: e.id, rank: i + 1, name: e.name.replacingOccurrences(of: "John", with: "Player"), handle: e.handle, points: e.points + 120 - i * 15, emoji: e.emoji, isMe: e.isMe)
        }
        default: return base
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Text("6 DAYS LEFT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.textMute)
                    }
                    .padding(.top, 8)

                    HStack(spacing: 0) {
                        Text("Leader")
                            .font(.system(size: 34, weight: .bold))
                        Text("board")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.warmGradient)
                    }

                    HStack(spacing: 18) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { i, name in
                            Button { tab = i } label: {
                                VStack(spacing: 6) {
                                    Text(name)
                                        .font(.system(size: 15, weight: tab == i ? .bold : .medium))
                                        .foregroundStyle(tab == i ? ZuvaroTheme.text : ZuvaroTheme.textMute)
                                    Rectangle()
                                        .fill(tab == i ? ZuvaroTheme.pink : .clear)
                                        .frame(height: 2)
                                }
                            }.buttonStyle(.plain)
                        }
                    }

                    ForEach(rows) { row in
                        leaderboardRow(row)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
        }
    }

    private func leaderboardRow(_ row: LeaderboardEntry) -> some View {
        HStack(spacing: 12) {
            Text("\(row.rank)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .frame(width: 28)
            Text(row.emoji).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.name).font(.system(size: 15, weight: .semibold))
                Text(row.handle).font(.system(size: 12)).foregroundStyle(ZuvaroTheme.textMute)
            }
            Spacer()
            Text("\(row.points)pts")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(row.rank == 1 ? ZuvaroTheme.orange : ZuvaroTheme.text)
        }
        .padding(14)
        .background(row.isMe ? ZuvaroTheme.pink.opacity(0.08) : ZuvaroTheme.card)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(row.isMe ? ZuvaroTheme.pink.opacity(0.3) : ZuvaroTheme.stroke, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
