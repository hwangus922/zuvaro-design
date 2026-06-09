import SwiftUI

enum AppLegal {
    static let privacyPolicyURL = URL(string: "https://hwangus922.github.io/zuvaro-design/privacy.html")!
    static let termsOfServiceURL = URL(string: "https://hwangus922.github.io/zuvaro-design/terms.html")!
    static let supportEmail = "support@zuvaro.app"
}

struct TermsPrivacyFooter: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 4) {
            Text("By continuing you agree to our")
                .foregroundStyle(ZuvaroTheme.textDim)
            Button("Terms") { openURL(AppLegal.termsOfServiceURL) }
                .foregroundStyle(ZuvaroTheme.pink)
            Text("and")
                .foregroundStyle(ZuvaroTheme.textDim)
            Button("Privacy Policy") { openURL(AppLegal.privacyPolicyURL) }
                .foregroundStyle(ZuvaroTheme.pink)
            Text(".")
                .foregroundStyle(ZuvaroTheme.textDim)
        }
        .font(.system(size: 11))
        .multilineTextAlignment(.center)
    }
}

struct LegalLinksSection: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LEGAL")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(ZuvaroTheme.textMute)
            legalRow("Privacy Policy", url: AppLegal.privacyPolicyURL)
            legalRow("Terms of Service", url: AppLegal.termsOfServiceURL)
        }
    }

    private func legalRow(_ title: String, url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            HStack {
                Text(title).font(.system(size: 15))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.textMute)
            }
            .padding(14)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct AgeConfirmationGate: View {
    @Binding var confirmed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $confirmed) {
                Text("I am 17 or older and agree to participate in user-generated dares at my own discretion.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.text)
            }
            .tint(ZuvaroTheme.pink)
            .padding(14)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct ReportUserSheet: View {
    let userName: String
    @Binding var details: String
    var isSubmitting: Bool
    var errorMessage: String?
    var onCancel: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Report \(userName)")
                    .font(.system(size: 20, weight: .bold))
                Text("Tell us what happened. Our team reviews reports within 24 hours.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.textMute)
                TextField("Describe the issue…", text: $details, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
                PrimaryButton(
                    title: isSubmitting ? "Sending..." : "Submit report",
                    enabled: !isSubmitting && details.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
                ) {
                    onSubmit()
                }
                Spacer()
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
