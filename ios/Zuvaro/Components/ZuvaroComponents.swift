import SwiftUI

struct ZuvaroTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 4) {
            tabButton(.home, icon: "house.fill", label: "Home")
            tabButton(.board, icon: "trophy.fill", label: "Board")
            tabButton(.me, icon: "person.fill", label: "Me")
        }
        .padding(6)
        .background(ZuvaroTheme.tabBarBg)
        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selection == tab
        Button {
            selection = tab
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                if isSelected {
                    Text(label)
                        .font(.system(size: 13, weight: .bold))
                }
            }
            .foregroundStyle(isSelected ? ZuvaroTheme.inkOnWarm : Color.white.opacity(0.6))
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.hook)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ZuvaroTheme.textMute)
                    .lineLimit(1)
                Spacer()
                Text(challenge.time)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(ZuvaroTheme.textDim)
            }
            Text(challenge.text)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ZuvaroTheme.text)
                .multilineTextAlignment(.leading)
            HStack {
                Spacer()
                Text(challenge.pointsLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(challenge.points != nil ? ZuvaroTheme.inkOnWarm : ZuvaroTheme.textMute)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background {
                        if challenge.points != nil {
                            Capsule().fill(ZuvaroTheme.warmGradient)
                        } else {
                            Capsule().fill(ZuvaroTheme.cardHi)
                        }
                    }
            }
        }
        .padding(16)
        .background(ZuvaroTheme.card)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ZuvaroTheme.stroke, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct QuestChainCard: View {
    let questDone: Int
    let questTotal: Int
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(questDone)/\(questTotal) daily challenges conquered")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .semibold))
                }
                HStack(spacing: 8) {
                    Text("Quest Chain")
                        .font(.system(size: 16, weight: .bold))
                    Text("refreshes in 3 hours")
                        .font(.system(size: 13, weight: .medium))
                        .opacity(0.75)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.22))
                        Capsule()
                            .fill(Color.black)
                            .frame(width: geo.size.width * CGFloat(questDone) / CGFloat(questTotal))
                    }
                }
                .frame(height: 6)
            }
            .foregroundStyle(ZuvaroTheme.inkOnWarm)
            .padding(16)
            .background(ZuvaroTheme.cardWarmGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: ZuvaroTheme.pink.opacity(0.25), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
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
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(ZuvaroTheme.warmGradient)
                    } else {
                        Capsule().fill(ZuvaroTheme.card)
                    }
                }
                .overlay(Capsule().stroke(ZuvaroTheme.strokeHi, lineWidth: isSelected ? 0 : 1))
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
            .background(ZuvaroTheme.card)
            .overlay(Circle().stroke(ZuvaroTheme.pink, lineWidth: 2))
            .clipShape(Circle())
    }
}
