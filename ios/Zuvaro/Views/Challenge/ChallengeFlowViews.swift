import SwiftUI
import PhotosUI
import UIKit

struct ChallengeDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Challenge", onBack: { appModel.pop() })
                Text(challenge.hook)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ZuvaroTheme.textMute)
                Text(challenge.text)
                    .font(.system(size: 28, weight: .bold))
                Text(challenge.rules)
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.textMute)
                    .lineSpacing(4)
                PrimaryButton(title: "Accept dare") {
                    appModel.navigate(to: .inProgress(challenge))
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct DareInProgressView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge
    @State private var seconds: Int

    init(challenge: Challenge) {
        self.challenge = challenge
        _seconds = State(initialValue: challenge.minutes * 60)
    }

    var body: some View {
        VStack(spacing: 24) {
            ScreenHeader(title: "Dare in progress", onBack: { appModel.pop() })
            Spacer()
            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(ZuvaroTheme.warmGradient)
            Text(challenge.text)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(title: "I did it — submit proof") {
                appModel.navigate(to: .submitProof(challenge))
            }
        }
        .padding(24)
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if seconds > 0 { seconds -= 1 }
        }
    }
}

struct SubmitProofView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge
    @State private var caption = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Submit proof", onBack: { appModel.pop() })
                Text(challenge.text).font(.system(size: 24, weight: .bold))
                Text("Upload a photo showing you completed this dare.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.textMute)

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedImage == nil ? ZuvaroTheme.strokeHi : ZuvaroTheme.success, style: StrokeStyle(lineWidth: 1, dash: selectedImage == nil ? [6] : []))
                            .frame(height: 180)
                        if let selectedImage {
                            selectedImage.resizable().scaledToFill().frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 8) {
                                Text("📷").font(.largeTitle)
                                Text("Tap to add photo proof").font(.system(size: 15, weight: .semibold))
                            }
                        }
                    }
                }
                .onChange(of: pickerItem) { _, item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            selectedImage = Image(uiImage: ui)
                        }
                    }
                }

                TextField("Caption (optional)", text: $caption)
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(challenge.rules)
                    .font(.system(size: 13))
                    .padding(14)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                PrimaryButton(title: "Submit proof · \(challenge.pointsLabel)", enabled: selectedImage != nil) {
                    appModel.navigate(to: .proofUploading(challenge))
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct ProofUploadingView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge

    var body: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.4)
            Text("Uploading proof…")
                .font(.system(size: 26, weight: .bold))
            Text(challenge.text)
                .font(.system(size: 14))
                .foregroundStyle(ZuvaroTheme.textMute)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                if !appModel.path.isEmpty { appModel.path.removeLast() }
                appModel.navigate(to: .proofPending(challenge))
            }
        }
    }
}

struct ProofPendingView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("PENDING REVIEW")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ZuvaroTheme.orange)
                Text("Proof submitted")
                    .font(.system(size: 28, weight: .bold))
                Text("We'll review your photo and credit points once approved.")
                    .font(.system(size: 14))
                    .foregroundStyle(ZuvaroTheme.textMute)
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "Back to Home") { appModel.popToRoot() }
                SecondaryTextButton(title: "View all submissions") { appModel.navigate(to: .submissions) }
                SecondaryTextButton(title: "Demo: simulate approval") {
                    if !appModel.path.isEmpty { appModel.path.removeLast() }
                    appModel.approveProof(for: challenge)
                }
                SecondaryTextButton(title: "Demo: simulate rejection") {
                    if !appModel.path.isEmpty { appModel.path.removeLast() }
                    appModel.rejectProof(for: challenge)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct ProofApprovedView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(ZuvaroTheme.warmGradient)
            Text("Proof approved!")
                .font(.system(size: 30, weight: .bold))
            if let pts = challenge.points {
                WarmGradientText(text: "+\(pts)pts", size: 44)
            }
            QuestChainCard(questDone: appModel.questDone, questTotal: appModel.questTotal)
            PrimaryButton(title: "Next dare") { appModel.popToRoot() }
            SecondaryTextButton(title: "Back to Home") { appModel.popToRoot() }
        }
        .padding(24)
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct ProofRejectedView: View {
    @EnvironmentObject private var appModel: AppModel
    let challenge: Challenge

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 56))
                .foregroundStyle(ZuvaroTheme.orange)
            Text("Proof rejected")
                .font(.system(size: 26, weight: .bold))
            Text("Your photo didn't pass review. Make sure the dare is clearly visible.")
                .font(.system(size: 14))
                .foregroundStyle(ZuvaroTheme.textMute)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Resubmit proof") { appModel.navigate(to: .submitProof(challenge)) }
            SecondaryTextButton(title: "Skip for now") { appModel.popToRoot() }
        }
        .padding(24)
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }
}

struct MySubmissionsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "My submissions", onBack: { appModel.pop() })
                ForEach(MockData.submissions) { sub in
                    Button {
                        switch sub.status {
                        case .pending: appModel.navigate(to: .proofPending(MockData.challenges[0]))
                        case .approved: appModel.navigate(to: .proofApproved(MockData.challenges[0]))
                        case .rejected: appModel.navigate(to: .proofRejected(MockData.challenges[2]))
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sub.dareTitle).font(.system(size: 14, weight: .semibold))
                                Text(sub.timeAgo).font(.system(size: 12)).foregroundStyle(ZuvaroTheme.textMute)
                            }
                            Spacer()
                            Text(sub.status.rawValue.capitalized)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor(sub.status).opacity(0.15))
                                .foregroundStyle(statusColor(sub.status))
                                .clipShape(Capsule())
                        }
                        .padding(14)
                        .background(ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
    }

    private func statusColor(_ status: SubmissionStatus) -> Color {
        switch status {
        case .pending: return ZuvaroTheme.orange
        case .approved: return ZuvaroTheme.success
        case .rejected: return ZuvaroTheme.pink
        }
    }
}
