import Foundation

struct UserProfile: Identifiable, Hashable, Codable {
    let id: UUID
    var displayName: String
    var handle: String
    var avatarEmoji: String
    var totalPoints: Int
    var questDone: Int
    var questTotal: Int
    var wins: Int
    var longestStreak: Int
    var challengesCompleted: Int
    var isAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case handle
        case avatarEmoji = "avatar_emoji"
        case totalPoints = "total_points"
        case questDone = "quest_done"
        case questTotal = "quest_total"
        case wins
        case longestStreak = "longest_streak"
        case challengesCompleted = "challenges_completed"
        case isAdmin = "is_admin"
    }
}

struct GroupRecord: Codable {
    let id: UUID
    let name: String
    let inviteCode: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case inviteCode = "invite_code"
    }
}

struct ChallengeRecord: Codable {
    let id: UUID
    let timeLabel: String
    let text: String
    let points: Int?
    let hook: String
    let minutes: Int
    let rules: String

    enum CodingKeys: String, CodingKey {
        case id, text, points, hook, minutes, rules
        case timeLabel = "time_label"
    }

    var asChallenge: Challenge {
        Challenge(
            id: id,
            time: timeLabel,
            text: text,
            points: points,
            hook: hook,
            minutes: minutes,
            rules: rules
        )
    }
}

struct SubmissionRecord: Codable {
    let id: UUID
    let userId: UUID
    let challengeId: UUID
    let caption: String?
    let photoPath: String
    let status: SubmissionStatus
    let pointsAwarded: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, caption, status
        case userId = "user_id"
        case challengeId = "challenge_id"
        case photoPath = "photo_path"
        case pointsAwarded = "points_awarded"
        case createdAt = "created_at"
    }
}

struct ChatMessageRecord: Codable {
    let id: UUID
    let groupId: UUID
    let userId: UUID
    let text: String
    let isDare: Bool
    let dareChallengeId: UUID?
    let createdAt: Date
    let profiles: ChatAuthorRecord?

    enum CodingKeys: String, CodingKey {
        case id, text
        case groupId = "group_id"
        case userId = "user_id"
        case isDare = "is_dare"
        case dareChallengeId = "dare_challenge_id"
        case createdAt = "created_at"
        case profiles
    }
}

struct ChatAuthorRecord: Codable {
    let displayName: String
    let avatarEmoji: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
    }
}

struct LeaderboardRecord: Codable {
    let groupId: UUID
    let userId: UUID
    let displayName: String
    let handle: String
    let avatarEmoji: String
    let totalPoints: Int
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case rank, handle
        case groupId = "group_id"
        case userId = "user_id"
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
        case totalPoints = "total_points"
    }
}

struct NotificationRecord: Codable {
    let id: UUID
    let title: String
    let body: String
    let kind: String
    let unread: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, body, kind, unread
        case createdAt = "created_at"
    }
}

struct NewSubmissionPayload: Encodable {
    let id: UUID
    let userId: UUID
    let challengeId: UUID
    let groupId: UUID?
    let caption: String?
    let photoPath: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, caption, status
        case userId = "user_id"
        case challengeId = "challenge_id"
        case groupId = "group_id"
        case photoPath = "photo_path"
    }
}

struct NewChatMessagePayload: Encodable {
    let groupId: UUID
    let userId: UUID
    let text: String
    let isDare: Bool
    let dareChallengeId: UUID?

    enum CodingKeys: String, CodingKey {
        case text
        case groupId = "group_id"
        case userId = "user_id"
        case isDare = "is_dare"
        case dareChallengeId = "dare_challenge_id"
    }
}

struct ProfileUpdatePayload: Encodable {
    let displayName: String
    let handle: String
    let avatarEmoji: String

    enum CodingKeys: String, CodingKey {
        case handle
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
    }
}
