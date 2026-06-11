import SwiftUI

struct ZuvaroTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 6) {
            tabButton(.home, emoji: "🏠", label: "Home")
            tabButton(.board, emoji: "🏆", label: "Board")
            tabButton(.me, emoji: "👤", label: "Me")
        }
        .padding(6)
        .background(ZuvaroTheme.tabBarBg)
        .overlay(Capsule().stroke(ZuvaroTheme.stroke, lineWidth: 1))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 16, y: 4)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab, emoji: String, label: String) -> some View {
        let isSelected = selection == tab
        Button {
            selection = tab
        } label: {
            HStack(spacing: 8) {
                Text(emoji).font(.system(size: 18))
                if isSelected {
                    Text(label)
                        .font(.system(size: 13, weight: .bold))
                }
            }
            .foregroundStyle(isSelected ? ZuvaroTheme.inkOnWarm : ZuvaroTheme.textMute)
            .padding(.horizontal, isSelected ? 18 : 14)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule().fill(ZuvaroTheme.warmGradient)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                if let sponsorLabel = challenge.sponsorLabel {
                    Text(sponsorLabel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.magenta)
                        .textCase(.uppercase)
                }
                Text(challenge.text)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(challenge.points == nil ? ZuvaroTheme.textDim : ZuvaroTheme.text)
                    .multilineTextAlignment(.leading)
                Text(challenge.hook)
                    .font(.system(size: 13))
                    .foregroundStyle(ZuvaroTheme.textMute)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            Text(challenge.pointsLabel)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(challenge.points != nil ? ZuvaroTheme.inkOnWarm : ZuvaroTheme.textMute)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    if challenge.points != nil {
                        Capsule().fill(ZuvaroTheme.pointsGradient)
                    } else {
                        Capsule().fill(ZuvaroTheme.cardHi)
                    }
                }
        }
        .padding(16)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }
}

struct PrizePoolCard: View {
    let pool: PrizePool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PRIZE POOL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(ZuvaroTheme.textMute)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .semibold))
                    Text(pool.refreshLabel)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(ZuvaroTheme.textDim)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(pool.formattedTotal)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(ZuvaroTheme.text)
                Text("top 5 split")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.textMute)
            }

            Text("Brands sponsor dares to fill the pool. Finish missions, earn points, and land in the top 5 to get paid.")
                .font(.system(size: 12))
                .foregroundStyle(ZuvaroTheme.textMute)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(Array(PrizePool.topFiveSplit.enumerated()), id: \.offset) { index, share in
                    VStack(spacing: 4) {
                        Text("#\(index + 1)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.textMute)
                        Text("\(Int(share * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(index == 0 ? ZuvaroTheme.orange : ZuvaroTheme.text)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ZuvaroTheme.cardHi)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
    }
}

struct TodayPointsCard: View {
    let points: Int
    let goalPoints: Int
    let questDone: Int
    let questTotal: Int
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TODAY'S POINTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11, weight: .semibold))
                        Text("refreshes in 3h")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(ZuvaroTheme.textDim)
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(points)pts")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.text)
                    Text("/ \(goalPoints)pts · \(questDone) out of \(questTotal)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ZuvaroTheme.textMute)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(ZuvaroTheme.cardHi)
                        Capsule()
                            .fill(ZuvaroTheme.warmGradient)
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(18)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var progress: CGFloat {
        guard questTotal > 0 else { return 0 }
        return CGFloat(questDone) / CGFloat(questTotal)
    }
}

struct QuestChainCard: View {
    let questDone: Int
    let questTotal: Int
    var action: (() -> Void)?

    var body: some View {
        TodayPointsCard(
            points: questDone * 20,
            goalPoints: questTotal * 68,
            questDone: questDone,
            questTotal: questTotal,
            action: action
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? ZuvaroTheme.inkOnWarm : ZuvaroTheme.textMute)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule().fill(ZuvaroTheme.warmGradient)
                    } else {
                        Capsule().fill(ZuvaroTheme.card)
                    }
                }
                .overlay(Capsule().stroke(ZuvaroTheme.strokeHi, lineWidth: isSelected ? 0 : 1))
                .shadow(color: isSelected ? ZuvaroTheme.pink.opacity(0.15) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct AvatarView: View {
    var emoji: String = "👑"
    var size: CGFloat = 40

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.45))
            .frame(width: size, height: size)
            .background(ZuvaroTheme.pink.opacity(0.14))
            .overlay(Circle().stroke(ZuvaroTheme.pink.opacity(0.35), lineWidth: 1.5))
            .clipShape(Circle())
    }
}

struct AdminBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 10, weight: .bold))
            Text("Admin")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(ZuvaroTheme.magenta)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(ZuvaroTheme.magenta.opacity(0.12))
        .clipShape(Capsule())
    }
}
