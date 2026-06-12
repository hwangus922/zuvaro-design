import Foundation
import Supabase

enum AnalyticsPreferences {
    static let enabledKey = "zuvaro_analytics_enabled"

    static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: enabledKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: enabledKey)
    }
}

struct AnalyticsEvent: Sendable {
    let name: String
    let properties: [String: String]

    static func screen(_ name: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "screen_viewed", properties: ["screen": name])
    }

    static func tab(_ tab: AppTab) -> AnalyticsEvent {
        AnalyticsEvent(name: "tab_selected", properties: ["tab": tab.analyticsName])
    }

    static func authCompleted(method: String, isSignUp: Bool) -> AnalyticsEvent {
        AnalyticsEvent(
            name: isSignUp ? "sign_up_completed" : "sign_in_completed",
            properties: ["method": method]
        )
    }
}

extension AppTab {
    var analyticsName: String {
        switch self {
        case .home: return "home"
        case .board: return "board"
        case .me: return "profile"
        }
    }
}

extension AppRoute {
    var analyticsScreenName: String {
        switch self {
        case .challenge: return "challenge_detail"
        case .inProgress: return "challenge_in_progress"
        case .submitProof: return "submit_proof"
        case .proofUploading: return "proof_uploading"
        case .proofPending: return "proof_pending"
        case .proofApproved: return "proof_approved"
        case .proofRejected: return "proof_rejected"
        case .questChain: return "quest_chain"
        case .search: return "search"
        case .submissions: return "submissions"
        case .chat: return "group_chat"
        case .createDare: return "create_dare"
        case .notifications: return "notifications"
        case .invite: return "invite_friends"
        case .settings: return "settings"
        case .editProfile: return "edit_profile"
        case .setUsername: return "set_username"
        case .privacy: return "privacy"
        case .blockedUsers: return "blocked_users"
        case .help: return "help_support"
        case .adminReview: return "admin_review"
        case .adminSubmission: return "admin_submission"
        case .signIn: return "sign_in"
        case .emailAuth: return "email_auth"
        }
    }
}

protocol AnalyticsServiceProtocol: Sendable {
    func track(_ event: AnalyticsEvent, userId: UUID?) async
}

private struct AnalyticsEventRecord: Encodable {
    let userId: UUID?
    let eventName: String
    let properties: [String: String]
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case eventName = "event_name"
        case properties
        case sessionId = "session_id"
    }
}

@MainActor
final class LiveAnalyticsService: AnalyticsServiceProtocol {
    private let client: SupabaseClient
    private let sessionId = UUID().uuidString

    init(client: SupabaseClient) {
        self.client = client
    }

    func track(_ event: AnalyticsEvent, userId: UUID?) async {
        guard AnalyticsPreferences.isEnabled || event.name == "analytics_preference_changed" else { return }

        let record = AnalyticsEventRecord(
            userId: userId,
            eventName: event.name,
            properties: event.properties,
            sessionId: sessionId
        )

        do {
            try await client
                .from("analytics_events")
                .insert(record)
                .execute()
        } catch {
            #if DEBUG
            print("[Analytics] failed to persist \(event.name): \(error.localizedDescription)")
            #endif
        }
    }
}

@MainActor
final class MockAnalyticsService: AnalyticsServiceProtocol {
    private let sessionId = UUID().uuidString

    func track(_ event: AnalyticsEvent, userId: UUID?) async {
        guard AnalyticsPreferences.isEnabled || event.name == "analytics_preference_changed" else { return }
        let user = userId?.uuidString ?? "anonymous"
        print("[Analytics] \(event.name) user=\(user) session=\(sessionId) \(event.properties)")
    }
}
