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
    @Published var blockedUsers: [BlockedUserRecord] = []

    @Published var authError: String?
    @Published var isAuthenticating = false
    @Published var isLoadingData = false
    @Published var pendingSubmissionId: UUID?
    @Published var pendingProofImageData: Data?
    @Published var pendingProofCaption: String?
    @Published var uploadError: String?
    @Published var profileSaveError: String?
    @Published var supportError: String?
    @Published var adminQueue: [AdminSubmission] = []
    @Published var isLoadingAdminQueue = false
    @Published var adminError: String?
    @Published var regions: [Region] = []
    @Published var regionalLeaderboard: [LeaderboardEntry] = []
    @Published var globalLeaderboard: [LeaderboardEntry] = []
    @Published var activePrizePool: PrizePool?
    @Published var regionError: String?
    @Published var currentRegionName: String?
    @Published var usernameError: String?

    private let services = ZuvaroServices.shared
    private var appleNonce = ""
    private var submissionPollTask: Task<Void, Never>?

    var pendingSubmissionsCount: Int {
        submissions.filter { $0.status == .pending }.count
    }

    var hasUnreadNotifications: Bool {
        notifications.contains { $0.unread }
    }

    var isAdmin: Bool {
        currentProfile?.isAdmin == true
    }

    var adminPendingCount: Int {
        adminQueue.filter { $0.status == .pending }.count
    }

    var needsRegionSetup: Bool {
        isAuthenticated && (currentProfile?.needsRegionSetup ?? false)
    }

    var needsUsernameSetup: Bool {
        isAuthenticated && !(currentProfile?.needsRegionSetup ?? false) && (currentProfile?.needsUsernameSetup ?? false)
    }

    var usRegions: [Region] {
        regions.filter { $0.kind == .usRegion }
    }

    var countries: [Region] {
        regions.filter { $0.kind == .country }
    }

    var referralProgress: Int {
        min(currentProfile?.referralCount ?? 0, 5)
    }

    var referralBonusEarned: Bool {
        currentProfile?.referralBonusClaimed ?? false
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
            if regions.isEmpty {
                await loadRegions()
            }
            if let profile = try? await services.profiles.fetchProfile(userId: userId) {
                currentProfile = profile
                applyProfile(profile)
                currentRegionName = regions.first { $0.id == profile.regionId }?.name
            }
            challenges = try await services.challenges.fetchActiveChallenges()
            submissions = try await services.submissions.fetchMySubmissions(userId: userId)
            notifications = try await services.notifications.fetchNotifications(userId: userId)
            blockedUsers = try await services.safety.fetchBlockedUsers(userId: userId)
            if let groupId = primaryGroup?.id {
                leaderboard = try await services.leaderboard.fetchFriendsBoard(groupId: groupId, currentUserId: userId)
                let allMessages = try await services.chat.fetchMessages(groupId: groupId, currentUserId: userId)
                let blockedIds = Set(blockedUsers.map(\.blockedId))
                chatMessages = allMessages.filter { !blockedIds.contains($0.userId) }
            }
            if let regionId = currentProfile?.regionId {
                activePrizePool = try await services.leaderboard.fetchActivePrizePool(regionId: regionId)
                let regionalRows = try await services.leaderboard.fetchRegionalBoard(
                    regionId: regionId,
                    currentUserId: userId
                )
                regionalLeaderboard = regionalRows.map { $0.withPayout(from: activePrizePool) }
            } else {
                activePrizePool = nil
                regionalLeaderboard = []
            }
            globalLeaderboard = try await services.leaderboard.fetchGlobalBoard(currentUserId: userId)
            if isAdmin {
                await loadAdminQueue(status: .pending)
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

    func loadRegions() async {
        do {
            regions = try await services.profiles.fetchRegions()
            if let regionId = currentProfile?.regionId {
                currentRegionName = regions.first { $0.id == regionId }?.name
            }
        } catch {
            regionError = error.localizedDescription
        }
    }

    func completeRegionSetup(regionCode: String, inviteCode: String?) async {
        regionError = nil
        do {
            let profile = try await services.profiles.setRegion(code: regionCode)
            currentProfile = profile
            applyProfile(profile)
            currentRegionName = regions.first { $0.code == regionCode }?.name
                ?? regions.first { $0.id == profile.regionId }?.name

            if let inviteCode, !inviteCode.isEmpty {
                let joinedGroup = try await services.profiles.joinGroup(inviteCode: inviteCode)
                primaryGroup = joinedGroup
                self.inviteCode = joinedGroup.inviteCode
            }

            await refreshAll()
        } catch {
            regionError = error.localizedDescription
        }
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

    /// Deletes the auth user and all associated data via the backend RPC.
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

    func checkUsernameAvailability(_ username: String) async -> Bool {
        if let validationMessage = UsernameValidator.validationMessage(for: username) {
            usernameError = validationMessage
            return false
        }
        usernameError = nil
        do {
            return try await services.profiles.isUsernameAvailable(username)
        } catch {
            usernameError = error.localizedDescription
            return false
        }
    }

    func setUsername(_ username: String) async -> Bool {
        guard currentProfile != nil else { return false }
        if let validationMessage = UsernameValidator.validationMessage(for: username) {
            usernameError = validationMessage
            return false
        }
        usernameError = nil
        do {
            let profile = try await services.profiles.setUsername(username)
            currentProfile = profile
            applyProfile(profile)
            await refreshAll()
            return true
        } catch {
            usernameError = friendlyUsernameError(error)
            return false
        }
    }

    func saveProfile(displayName: String, handle: String) async -> Bool {
        guard let userId = currentProfile?.id else { return false }
        profileSaveError = nil
        usernameError = nil
        do {
            let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            let nextHandle = UsernameValidator.handle(for: handle)
            let handleChanged = nextHandle != currentProfile?.handle

            if handleChanged {
                if let validationMessage = UsernameValidator.validationMessage(for: handle) {
                    profileSaveError = validationMessage
                    return false
                }
                let profile = try await services.profiles.setUsername(handle)
                currentProfile = profile
                applyProfile(profile)
            }

            if trimmedName != currentProfile?.displayName {
                let profile = try await services.profiles.updateProfile(
                    userId: userId,
                    displayName: trimmedName,
                    handle: currentProfile?.handle ?? nextHandle,
                    avatarEmoji: currentProfile?.avatarEmoji ?? "🍳"
                )
                currentProfile = profile
                applyProfile(profile)
            }

            await refreshAll()
            return true
        } catch {
            profileSaveError = friendlyUsernameError(error)
            return false
        }
    }

    private func friendlyUsernameError(_ error: Error) -> String {
        let message = error.localizedDescription.lowercased()
        if message.contains("already taken") || message.contains("duplicate") || message.contains("unique") {
            return "That username is already taken."
        }
        return error.localizedDescription
    }

    func postCustomDare(text: String, points: Int) async {
        guard let groupId = primaryGroup?.id,
              let userId = services.auth.currentUserId ?? currentProfile?.id else { return }
        do {
            try await services.chat.sendCustomDare(groupId: groupId, userId: userId, text: text, points: points)
            await refreshAll()
        } catch {
            authError = error.localizedDescription
        }
    }

    func unblockUser(_ blockedUserId: UUID) async {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return }
        do {
            try await services.safety.unblock(userId: userId, blockedUserId: blockedUserId)
            blockedUsers.removeAll { $0.blockedId == blockedUserId }
            await refreshAll()
        } catch {
            supportError = error.localizedDescription
        }
    }

    func blockUser(_ blockedUserId: UUID) async {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return }
        do {
            try await services.safety.block(userId: userId, blockedUserId: blockedUserId)
            await refreshAll()
        } catch {
            supportError = error.localizedDescription
        }
    }

    func loadAdminQueue(status: SubmissionStatus? = .pending) async {
        guard isAdmin else { return }
        isLoadingAdminQueue = true
        adminError = nil
        defer { isLoadingAdminQueue = false }
        do {
            adminQueue = try await services.submissions.fetchAdminSubmissions(status: status)
        } catch {
            adminError = error.localizedDescription
        }
    }

    func loadProofPhoto(path: String) async throws -> Data {
        try await services.submissions.downloadProofPhoto(path: path)
    }

    func reviewSubmission(id: UUID, approve: Bool, reviewNote: String?) async -> Bool {
        guard isAdmin, let reviewerId = services.auth.currentUserId ?? currentProfile?.id else { return false }
        adminError = nil
        do {
            try await services.submissions.reviewSubmission(
                id: id,
                reviewerId: reviewerId,
                status: approve ? .approved : .rejected,
                reviewNote: reviewNote
            )
            adminQueue.removeAll { $0.id == id }
            await refreshAll()
            return true
        } catch {
            adminError = error.localizedDescription
            return false
        }
    }

    func reportSupportIssue(_ text: String) async -> Bool {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return false }
        supportError = nil
        do {
            try await services.safety.reportIssue(
                userId: userId,
                details: text,
                reportedUserId: nil,
                reportedMessageId: nil,
                reportType: "support"
            )
            return true
        } catch {
            supportError = error.localizedDescription
            return false
        }
    }

    func reportUser(reportedUserId: UUID, messageId: UUID?, details: String) async -> Bool {
        guard let userId = services.auth.currentUserId ?? currentProfile?.id else { return false }
        supportError = nil
        let reportType = messageId == nil ? "user" : "message"
        do {
            try await services.safety.reportIssue(
                userId: userId,
                details: details,
                reportedUserId: reportedUserId,
                reportedMessageId: messageId,
                reportType: reportType
            )
            return true
        } catch {
            supportError = error.localizedDescription
            return false
        }
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
