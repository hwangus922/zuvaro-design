import AuthenticationServices
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var showOnboarding = true
    @Published var selectedTab: AppTab = .home
    @Published var path = NavigationPath()
    @Published var questDone = 1
    @Published var questTotal = 5
    @Published var totalPoints = 70

    @Published var isAuthenticated = false
    @Published var currentProfile: UserProfile?
    @Published var primaryGroup: GroupRecord?
    @Published var inviteCode = "chaos-crew"

    @Published var challenges: [Challenge] = MockData.challenges
    @Published var submissions: [Submission] = MockData.submissions
    @Published var leaderboard: [LeaderboardEntry] = MockData.friendsBoard
    @Published var chatMessages: [ChatMessage] = MockData.chatMessages
    @Published var notifications: [AppNotification] = MockData.notifications

    @Published var authError: String?
    @Published var isAuthenticating = false
    @Published var isLoadingData = false
    @Published var pendingSubmissionId: UUID?
    @Published var pendingProofImageData: Data?
    @Published var pendingProofCaption: String?
    @Published var uploadError: String?

    private let services = ZuvaroServices.shared
    private var appleNonce = ""
    private var submissionPollTask: Task<Void, Never>?

    var pendingSubmissionsCount: Int {
        submissions.filter { $0.status == .pending }.count
    }

    var hasUnreadNotifications: Bool {
        notifications.contains { $0.unread }
    }

    func bootstrap() async {
        if AppConfig.usesMockBackend {
            isAuthenticated = true
            showOnboarding = false
            await refreshAll()
            return
        }

        do {
            if let userId = try await services.auth.restoreSession() {
                try await finishSignIn(userId: userId)
            }
        } catch {
            isAuthenticated = false
        }
    }

    func signUp(email: String, password: String) async {
        await authenticate {
            try await services.auth.signUp(email: email, password: password)
        }
    }

    func signIn(email: String, password: String) async {
        await authenticate {
            try await services.auth.signIn(email: email, password: password)
        }
    }

    func prepareAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AppleSignInSupport.randomNonce()
        appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = AppleSignInSupport.sha256(nonce)
    }

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        authError = nil
        switch result {
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                authError = error.localizedDescription
            }
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                authError = "Apple sign-in failed."
                return
            }
            await authenticate {
                try await services.auth.signInWithApple(idToken: idToken, nonce: appleNonce)
            }
        }
    }

    private func authenticate(userIdProvider: () async throws -> UUID) async {
        authError = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            let userId = try await userIdProvider()
            try await finishSignIn(userId: userId)
        } catch {
            authError = error.localizedDescription
        }
    }

    private func finishSignIn(userId: UUID) async throws {
        let group = try await services.profiles.ensurePrimaryGroup(userId: userId)
        let profile = try await services.profiles.fetchProfile(userId: userId)

        primaryGroup = group
        inviteCode = group.inviteCode
        currentProfile = profile
        applyProfile(profile)
        isAuthenticated = true
        showOnboarding = false
        await refreshAll()
    }

    func refreshAll() async {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return }
        isLoadingData = true
        defer { isLoadingData = false }

        do {
            challenges = try await services.challenges.fetchActiveChallenges()
            submissions = try await services.submissions.fetchMySubmissions(userId: userId)
            notifications = try await services.notifications.fetchNotifications(userId: userId)
            if let groupId = primaryGroup?.id {
                leaderboard = try await services.leaderboard.fetchFriendsBoard(groupId: groupId, currentUserId: userId)
                chatMessages = try await services.chat.fetchMessages(groupId: groupId, currentUserId: userId)
            }
            if let profile = try? await services.profiles.fetchProfile(userId: userId) {
                currentProfile = profile
                applyProfile(profile)
            }
        } catch {
            authError = error.localizedDescription
        }
    }

    private func applyProfile(_ profile: UserProfile) {
        questDone = profile.questDone
        questTotal = profile.questTotal
        totalPoints = profile.totalPoints
    }

    func completeOnboarding() {
        showOnboarding = false
    }

    func signOut() async {
        submissionPollTask?.cancel()
        submissionPollTask = nil
        do {
            try await services.auth.signOut()
        } catch {
            authError = error.localizedDescription
        }
        isAuthenticated = false
        currentProfile = nil
        primaryGroup = nil
        showOnboarding = true
        path = NavigationPath()
    }

    func deleteAccount() async {
        guard let userId = currentProfile?.id else { return }
        do {
            try await services.profiles.deleteAccount(userId: userId)
            await signOut()
        } catch {
            authError = error.localizedDescription
        }
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func openChallenge(_ challenge: Challenge) {
        navigate(to: .challenge(challenge))
    }

    func challenge(for id: UUID) -> Challenge? {
        challenges.first { $0.id == id }
    }

    func submitProof(challenge: Challenge, imageData: Data, caption: String) async throws {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return }
        let submission = try await services.submissions.submitProof(
            userId: userId,
            challenge: challenge,
            groupId: primaryGroup?.id,
            imageData: imageData,
            caption: caption
        )
        submissions.insert(submission, at: 0)
        pendingSubmissionId = submission.id
        startSubmissionPolling(submissionId: submission.id, challenge: challenge)
    }

    private func startSubmissionPolling(submissionId: UUID, challenge: Challenge) {
        submissionPollTask?.cancel()
        submissionPollTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard let latest = try? await services.submissions.fetchSubmission(id: submissionId) else { continue }
                await MainActor.run {
                    if let index = submissions.firstIndex(where: { $0.id == submissionId }) {
                        submissions[index] = latest
                    }
                    if latest.status != .pending {
                        pendingSubmissionId = nil
                        Task { await refreshAll() }
                        switch latest.status {
                        case .approved:
                            if path.isEmpty == false { path.removeLast() }
                            navigate(to: .proofApproved(challenge))
                        case .rejected:
                            if path.isEmpty == false { path.removeLast() }
                            navigate(to: .proofRejected(challenge))
                        case .pending:
                            break
                        }
                        submissionPollTask?.cancel()
                    }
                }
            }
        }
    }

    #if DEBUG
    func approveProof(for challenge: Challenge) {
        questDone = min(questTotal, questDone + 1)
        if let pts = challenge.points { totalPoints += pts }
        navigate(to: .proofApproved(challenge))
    }

    func rejectProof(for challenge: Challenge) {
        navigate(to: .proofRejected(challenge))
    }
    #endif
}
