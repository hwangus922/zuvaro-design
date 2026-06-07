import Foundation

@MainActor
final class ZuvaroServices {
    static let shared = ZuvaroServices()

    let auth: AuthServiceProtocol
    let challenges: ChallengeRepositoryProtocol
    let submissions: SubmissionServiceProtocol
    let chat: ChatServiceProtocol
    let leaderboard: LeaderboardServiceProtocol
    let notifications: NotificationServiceProtocol
    let profiles: ProfileServiceProtocol

    private init() {
        if let client = SupabaseManager.shared {
            auth = LiveAuthService(client: client)
            challenges = LiveChallengeRepository(client: client)
            submissions = LiveSubmissionService(client: client)
            chat = LiveChatService(client: client)
            leaderboard = LiveLeaderboardService(client: client)
            notifications = LiveNotificationService(client: client)
            profiles = LiveProfileService(client: client)
        } else {
            auth = MockAuthService()
            challenges = MockChallengeRepository()
            submissions = MockSubmissionService()
            chat = MockChatService()
            leaderboard = MockLeaderboardService()
            notifications = MockNotificationService()
            profiles = MockProfileService()
        }
    }
}
