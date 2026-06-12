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
    let safety: SafetyServiceProtocol
    let analytics: AnalyticsServiceProtocol
    let phone: PhoneServiceProtocol

    private init() {
        if let client = SupabaseManager.shared {
            auth = LiveAuthService(client: client)
            challenges = LiveChallengeRepository(client: client)
            submissions = LiveSubmissionService(client: client)
            chat = LiveChatService(client: client)
            leaderboard = LiveLeaderboardService(client: client)
            notifications = LiveNotificationService(client: client)
            profiles = LiveProfileService(client: client)
            safety = LiveSafetyService(client: client)
            analytics = LiveAnalyticsService(client: client)
            phone = LivePhoneService(client: client)
        } else {
            #if !DEBUG
            fatalError("Supabase is required in non-debug builds. Configure SUPABASE_URL and SUPABASE_ANON_KEY.")
            #endif
            auth = MockAuthService()
            challenges = MockChallengeRepository()
            submissions = MockSubmissionService()
            chat = MockChatService()
            leaderboard = MockLeaderboardService()
            notifications = MockNotificationService()
            profiles = MockProfileService()
            safety = MockSafetyService()
            analytics = MockAnalyticsService()
            phone = MockPhoneService()
        }
    }
}
