import SwiftUI

enum ZuvaroTheme {
    static let screenBg = Color(hex: 0xF3F2F7)
    static let bg = Color.white
    static let card = Color.white
    static let cardHi = Color(hex: 0xF4F3F8)
    static let pink = Color(hex: 0xFF2D95)
    static let magenta = Color(hex: 0xC01686)
    static let orange = Color(hex: 0xFF6A2C)
    static let text = Color(hex: 0x0A0A0F)
    static let textMute = Color.black.opacity(0.55)
    static let textDim = Color.black.opacity(0.38)
    static let inkOnWarm = Color(hex: 0x170006)
    static let stroke = Color.black.opacity(0.06)
    static let strokeHi = Color.black.opacity(0.12)
    static let tabBarBg = Color.white
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

    static let pointsGradient = LinearGradient(
        colors: [Color(hex: 0xFF8A3D), orange, pink],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func cardShadow() -> some View {
        Color.clear.shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
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

struct PageTitle: View {
    let text: String

    var body: some View {
        WarmGradientText(text: text, size: 34, weight: .bold)
    }
}

struct AuraBackground: View {
    var body: some View {
        ZStack {
            ZuvaroTheme.screenBg.ignoresSafeArea()
            RadialGradient(
                colors: [ZuvaroTheme.pink.opacity(0.12), ZuvaroTheme.orange.opacity(0.08), .clear],
                center: .bottom,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [ZuvaroTheme.magenta.opacity(0.08), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 280
            )
            .ignoresSafeArea()
        }
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
                .frame(height: 52)
                .background(ZuvaroTheme.warmGradient)
                .clipShape(Capsule())
                .shadow(color: ZuvaroTheme.pink.opacity(0.25), radius: 12, y: 6)
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
    var showsLogo = false
    var useGradientTitle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showsLogo {
                ZuvaroLogo(style: .wordmark, size: .small)
            }
            HStack(spacing: 12) {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.text)
                            .frame(width: 36, height: 36)
                            .background(ZuvaroTheme.card)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    }
                }
                if useGradientTitle {
                    PageTitle(text: title)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.text)
                }
                Spacer()
            }
        }
    }
}
