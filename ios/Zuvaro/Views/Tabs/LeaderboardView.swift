import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var tab = 0
    private let tabs = ["Friends", "Club", "Global"]

    private var rows: [LeaderboardEntry] {
        switch tab {
        case 1: return appModel.regionalLeaderboard
        case 2: return appModel.globalLeaderboard
        default: return appModel.leaderboard
        }
    }

    private var showsPrizePool: Bool {
        tab == 1 && appModel.activePrizePool != nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            AuraBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PageTitle(text: "Leaderboard")

                    HStack(spacing: 8) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { i, name in
                            FilterChip(title: name, isSelected: tab == i) { tab = i }
                        }
                    }

                    if showsPrizePool, let pool = appModel.activePrizePool {
                        PrizePoolCard(pool: pool)
                    } else if tab == 0 {
                        Text("Crew rankings are for bragging rights. Switch to Club to compete for the weekly prize pool.")
                            .font(.system(size: 12))
                            .foregroundStyle(ZuvaroTheme.textMute)
                    }

                    ForEach(rows) { row in
                        leaderboardRow(row)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
    }

    private func leaderboardRow(_ row: LeaderboardEntry) -> some View {
        HStack(spacing: 12) {
            Text("\(row.rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(row.rank == 1 ? ZuvaroTheme.orange : ZuvaroTheme.textMute)
                .frame(width: 24, alignment: .leading)
            AvatarView(emoji: row.emoji, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.isMe ? "You" : row.name)
                    .font(.system(size: 15, weight: .semibold))
                Text(row.handle)
                    .font(.system(size: 12))
                    .foregroundStyle(ZuvaroTheme.textMute)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let payout = row.estimatedPayoutLabel, showsPrizePool {
                    Text(payout)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
                Text("\(row.points)pts")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(row.rank == 1 ? ZuvaroTheme.orange : ZuvaroTheme.text)
            }
        }
        .padding(14)
        .background(row.isMe ? ZuvaroTheme.pink.opacity(0.08) : ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(row.isMe ? 0.06 : 0.04), radius: 8, y: 2)
    }
}
