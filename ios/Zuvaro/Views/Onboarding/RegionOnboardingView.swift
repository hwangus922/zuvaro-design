import SwiftUI

struct RegionOnboardingView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var step: Step = .locationType
    @State private var inviteCode = ""
    @State private var isSaving = false

    private enum Step {
        case locationType
        case usRegion
        case country
    }

    var body: some View {
        ZStack {
            ZuvaroTheme.bg.ignoresSafeArea()
            AuraBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZuvaroLogo(style: .wordmark, size: .medium)
                    Text("Where are you based?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.text)
                    Text("We'll put you on your regional leaderboard and match you with players nearby.")
                        .font(.system(size: 15))
                        .foregroundStyle(ZuvaroTheme.textMute)

                    switch step {
                    case .locationType:
                        locationTypeStep
                    case .usRegion:
                        regionList(appModel.usRegions) { code in
                            Task { await saveRegion(code: code) }
                        }
                    case .country:
                        regionList(appModel.countries) { code in
                            Task { await saveRegion(code: code) }
                        }
                    }

                    if step != .locationType {
                        SecondaryTextButton(title: "Back") {
                            withAnimation { step = .locationType }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("HAVE AN INVITE CODE?")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.textMute)
                        TextField("Optional — friend's crew code", text: $inviteCode)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(ZuvaroTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if let error = appModel.regionError {
                        Text(error)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.orange)
                    }

                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
        }
        .task {
            await appModel.loadRegions()
        }
    }

    private var locationTypeStep: some View {
        VStack(spacing: 12) {
            locationButton(title: "United States", subtitle: "Pick your US region") {
                withAnimation { step = .usRegion }
            }
            locationButton(title: "Another country", subtitle: "Pick your country") {
                withAnimation { step = .country }
            }
        }
    }

    private func locationButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 16, weight: .semibold))
                    Text(subtitle).font(.system(size: 13)).foregroundStyle(ZuvaroTheme.textMute)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(ZuvaroTheme.textMute)
            }
            .foregroundStyle(ZuvaroTheme.text)
            .padding(16)
            .background(ZuvaroTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func regionList(_ regions: [Region], onSelect: @escaping (String) -> Void) -> some View {
        VStack(spacing: 10) {
            ForEach(regions) { region in
                Button { onSelect(region.code) } label: {
                    HStack {
                        Text(region.name)
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ZuvaroTheme.textMute)
                    }
                    .foregroundStyle(ZuvaroTheme.text)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
        }
    }

    private func saveRegion(code: String) async {
        isSaving = true
        defer { isSaving = false }
        let trimmedInvite = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        await appModel.completeRegionSetup(
            regionCode: code,
            inviteCode: trimmedInvite.isEmpty ? nil : trimmedInvite
        )
    }
}
