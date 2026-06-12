import SwiftUI

/// Knotted-arrow mark — Canvas draw matches website `ZMark` (SVG masks fail in asset catalog).
struct ZuvaroMark: View {
    var size: CGFloat = 32
    var color: Color = ZuvaroTheme.text

    private let strokeWidth: CGFloat = 7
    private let pillFrame = CGRect(x: 12, y: 38, width: 76, height: 24)
    private let pillRadius: CGFloat = 12
    private let knotCenter = CGPoint(x: 62, y: 38)
    private let knotRadius: CGFloat = 9.8

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 100
            let stroke = strokeWidth * scale
            let style = StrokeStyle(lineWidth: stroke, lineCap: .round, lineJoin: .round)
            let shading = GraphicsContext.Shading.color(color)

            func pillPath(degrees: Double) -> Path {
                let rect = CGRect(
                    x: pillFrame.minX * scale,
                    y: pillFrame.minY * scale,
                    width: pillFrame.width * scale,
                    height: pillFrame.height * scale
                )
                let path = Path(roundedRect: rect, cornerRadius: pillRadius * scale, style: .continuous)
                var transform = CGAffineTransform(translationX: 50 * scale, y: 50 * scale)
                transform = transform.rotated(by: CGFloat(degrees) * .pi / 180)
                transform = transform.translatedBy(x: -50 * scale, y: -50 * scale)
                return path.applying(transform)
            }

            context.drawLayer { layer in
                layer.stroke(pillPath(degrees: -45), with: shading, style: style)
                let hole = CGRect(
                    x: (knotCenter.x - knotRadius) * scale,
                    y: (knotCenter.y - knotRadius) * scale,
                    width: knotRadius * 2 * scale,
                    height: knotRadius * 2 * scale
                )
                layer.blendMode = .destinationOut
                layer.fill(Path(ellipseIn: hole), with: .color(.white))
            }

            context.stroke(pillPath(degrees: 45), with: shading, style: style)

            var arrow = Path()
            arrow.move(to: CGPoint(x: 76 * scale, y: 14 * scale))
            arrow.addLine(to: CGPoint(x: 86 * scale, y: 14 * scale))
            arrow.addLine(to: CGPoint(x: 86 * scale, y: 24 * scale))
            context.stroke(arrow, with: shading, style: style)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ZuvaroLogo: View {
    enum Style {
        case mark
        case wordmark
    }

    enum Size {
        case small
        case medium
        case large

        var markSide: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 40
            case .large: return 56
            }
        }

        var textSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 26
            case .large: return 34
            }
        }

        var spacing: CGFloat {
            switch self {
            case .small: return 7
            case .medium: return 9
            case .large: return 10
            }
        }
    }

    var style: Style = .wordmark
    var size: Size = .medium

    var body: some View {
        HStack(alignment: .center, spacing: size.spacing) {
            ZuvaroMark(size: size.markSide)

            if style == .wordmark {
                Text("zuvaro")
                    .font(.system(size: size.textSize, weight: .heavy))
                    .tracking(-0.04 * size.textSize)
                    .foregroundStyle(ZuvaroTheme.text)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Zuvaro")
    }
}

struct ZuvaroBrandBar: View {
    var size: ZuvaroLogo.Size = .small
    var trailing: AnyView?

    init(size: ZuvaroLogo.Size = .small, @ViewBuilder trailing: () -> some View = { EmptyView() }) {
        self.size = size
        self.trailing = AnyView(trailing())
    }

    var body: some View {
        HStack {
            ZuvaroLogo(style: .wordmark, size: size)
            Spacer()
            trailing
        }
    }
}
