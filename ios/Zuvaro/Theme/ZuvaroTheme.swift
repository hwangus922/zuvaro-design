import SwiftUI

enum ZuvaroTheme {
    static let bg = Color(hex: 0xFFFFFF)
    static let card = Color(hex: 0xF4F3F8)
    static let cardHi = Color(hex: 0xEEEDF3)
    static let pink = Color(hex: 0xFF2D87)
    static let magenta = Color(hex: 0xC81E5B)
    static let orange = Color(hex: 0xFF6A2C)
    static let text = Color(hex: 0x0A0A0F)
    static let textMute = Color.black.opacity(0.62)
    static let textDim = Color.black.opacity(0.38)
    static let inkOnWarm = Color(hex: 0x170006)
    static let stroke = Color.black.opacity(0.06)
    static let strokeHi = Color.black.opacity(0.14)
    static let tabBarBg = Color(red: 15/255, green: 15/255, blue: 20/255).opacity(0.92)
    static let success = Color(hex: 0x22C55E)

    static let warmGradient = LinearGradient(
        colors: [orange, pink, magenta],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardWarmGradient = LinearGradient(
        colors: [magenta, pink, orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct WarmGradientText: View {
    let text: String
    var size: CGFloat = 44
    var weight: Font.Weight = .heavy

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundStyle(ZuvaroTheme.warmGradient)
    }
}

struct AuraBackground: View {
    var body: some View {
        RadialGradient(
            colors: [ZuvaroTheme.magenta.opacity(0.18), ZuvaroTheme.pink.opacity(0.10), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 320
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct PrimaryButton: View {
    let title: String
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ZuvaroTheme.inkOnWarm)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ZuvaroTheme.warmGradient)
                .clipShape(Capsule())
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.45)
    }
}

struct SecondaryTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ZuvaroTheme.textMute)
        }
        .frame(height: 40)
    }
}

struct ScreenHeader: View {
    let title: String
    var onBack: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ZuvaroTheme.text)
                        .frame(width: 36, height: 36)
                        .background(ZuvaroTheme.card)
                        .clipShape(Circle())
                }
            }
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ZuvaroTheme.text)
            Spacer()
        }
    }
}
