import SwiftUI
import UIKit

struct AdminReviewView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var filter: SubmissionStatus? = .pending

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Review proofs", onBack: { appModel.pop() })

                AdminBadge()

                HStack(spacing: 10) {
                    FilterChip(title: "Pending", isSelected: filter == .pending) { filter = .pending }
                    FilterChip(title: "Approved", isSelected: filter == .approved) { filter = .approved }
                    FilterChip(title: "Rejected", isSelected: filter == .rejected) { filter = .rejected }
                    FilterChip(title: "All", isSelected: filter == nil) { filter = nil }
                }

                if appModel.isLoadingAdminQueue {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if appModel.adminQueue.isEmpty {
                    Text(emptyMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(ZuvaroTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ForEach(appModel.adminQueue) { submission in
                        Button {
                            appModel.navigate(to: .adminSubmission(submission))
                        } label: {
                            adminRow(submission)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let error = appModel.adminError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .task(id: filter) {
            await appModel.loadAdminQueue(status: filter)
        }
        .refreshable {
            await appModel.loadAdminQueue(status: filter)
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .pending: return "No pending proofs to review."
        case .approved: return "No approved submissions yet."
        case .rejected: return "No rejected submissions."
        case nil: return "No submissions found."
        }
    }

    private func adminRow(_ submission: AdminSubmission) -> some View {
        HStack(spacing: 12) {
            AvatarView(emoji: submission.submitterEmoji, size: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.dareTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ZuvaroTheme.text)
                    .lineLimit(2)
                Text("\(submission.submitterName) · \(submission.submitterHandle)")
                    .font(.system(size: 12))
                    .foregroundStyle(ZuvaroTheme.textMute)
                Text(submission.timeAgo)
                    .font(.system(size: 11))
                    .foregroundStyle(ZuvaroTheme.textDim)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(submission.status.rawValue.capitalized)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(submission.status).opacity(0.15))
                    .foregroundStyle(statusColor(submission.status))
                    .clipShape(Capsule())
                if let points = submission.points {
                    Text("+\(points)pts")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
            }
        }
        .padding(14)
        .background(ZuvaroTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusColor(_ status: SubmissionStatus) -> Color {
        switch status {
        case .pending: return ZuvaroTheme.orange
        case .approved: return ZuvaroTheme.success
        case .rejected: return ZuvaroTheme.pink
        }
    }
}

struct AdminSubmissionDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    let submission: AdminSubmission

    @State private var photoData: Data?
    @State private var isLoadingPhoto = true
    @State private var isReviewing = false
    @State private var showRejectSheet = false
    @State private var rejectNote = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Proof review", onBack: { appModel.pop() })

                HStack(spacing: 12) {
                    AvatarView(emoji: submission.submitterEmoji, size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(submission.submitterName)
                            .font(.system(size: 16, weight: .semibold))
                        Text(submission.submitterHandle)
                            .font(.system(size: 13))
                            .foregroundStyle(ZuvaroTheme.textMute)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("DARE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                    Text(submission.dareTitle)
                        .font(.system(size: 18, weight: .bold))
                    if let points = submission.points {
                        Text("+\(points)pts")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(ZuvaroTheme.orange)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ZuvaroTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let caption = submission.caption, !caption.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CAPTION")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(ZuvaroTheme.textMute)
                        Text(caption)
                            .font(.system(size: 14))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("PROOF PHOTO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ZuvaroTheme.textMute)

                    Group {
                        if isLoadingPhoto {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 280)
                        } else if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Text("Could not load proof photo.")
                                .font(.system(size: 13))
                                .foregroundStyle(ZuvaroTheme.textMute)
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                        }
                    }
                    .background(ZuvaroTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if submission.status == .pending {
                    VStack(spacing: 12) {
                        PrimaryButton(title: isReviewing ? "Approving…" : "Approve proof", enabled: !isReviewing) {
                            Task { await review(approve: true) }
                        }

                        SecondaryTextButton(title: "Reject proof") {
                            showRejectSheet = true
                        }
                        .disabled(isReviewing)
                    }
                } else {
                    Text("Already \(submission.status.rawValue).")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZuvaroTheme.textMute)
                        .frame(maxWidth: .infinity)
                }

                if let error = appModel.adminError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundStyle(ZuvaroTheme.orange)
                }
            }
            .padding(24)
        }
        .background(ZuvaroTheme.bg)
        .navigationBarHidden(true)
        .task {
            await loadPhoto()
        }
        .alert("Reject proof", isPresented: $showRejectSheet) {
            TextField("Reason (optional)", text: $rejectNote)
            Button("Reject", role: .destructive) {
                Task { await review(approve: false) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The player will be notified.")
        }
    }

    private func loadPhoto() async {
        isLoadingPhoto = true
        defer { isLoadingPhoto = false }
        photoData = try? await appModel.loadProofPhoto(path: submission.photoPath)
    }

    private func review(approve: Bool) async {
        isReviewing = true
        defer { isReviewing = false }
        let note = approve ? nil : (rejectNote.isEmpty ? nil : rejectNote)
        let success = await appModel.reviewSubmission(
            id: submission.id,
            approve: approve,
            reviewNote: note
        )
        if success {
            appModel.pop()
        }
    }
}
