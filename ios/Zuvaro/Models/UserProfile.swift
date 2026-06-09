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
    var regionId: UUID?
    var referralCount: Int
    var referralBonusClaimed: Bool
    var usernameCustomized: Bool

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
        case regionId = "region_id"
        case referralCount = "referral_count"
        case referralBonusClaimed = "referral_bonus_claimed"
        case usernameCustomized = "username_customized"
    }

    var needsRegionSetup: Bool { regionId == nil }
    var needsUsernameSetup: Bool { !usernameCustomized }
    var referralsUntilBonus: Int { max(0, 5 - referralCount) }

    init(
        id: UUID,
        displayName: String,
        handle: String,
        avatarEmoji: String,
        totalPoints: Int,
        questDone: Int,
        questTotal: Int,
        wins: Int,
        longestStreak: Int,
        challengesCompleted: Int,
        isAdmin: Bool,
        regionId: UUID? = nil,
        referralCount: Int = 0,
        referralBonusClaimed: Bool = false,
        usernameCustomized: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.handle = handle
        self.avatarEmoji = avatarEmoji
        self.totalPoints = totalPoints
        self.questDone = questDone
        self.questTotal = questTotal
        self.wins = wins
        self.longestStreak = longestStreak
        self.challengesCompleted = challengesCompleted
        self.isAdmin = isAdmin
        self.regionId = regionId
        self.referralCount = referralCount
        self.referralBonusClaimed = referralBonusClaimed
        self.usernameCustomized = usernameCustomized
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        handle = try container.decode(String.self, forKey: .handle)
        avatarEmoji = try container.decode(String.self, forKey: .avatarEmoji)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        questDone = try container.decode(Int.self, forKey: .questDone)
        questTotal = try container.decode(Int.self, forKey: .questTotal)
        wins = try container.decode(Int.self, forKey: .wins)
        longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        challengesCompleted = try container.decode(Int.self, forKey: .challengesCompleted)
        isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
        regionId = try container.decodeIfPresent(UUID.self, forKey: .regionId)
        referralCount = try container.decodeIfPresent(Int.self, forKey: .referralCount) ?? 0
        referralBonusClaimed = try container.decodeIfPresent(Bool.self, forKey: .referralBonusClaimed) ?? false
        usernameCustomized = try container.decodeIfPresent(Bool.self, forKey: .usernameCustomized) ?? true
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
    let challengeId: UUID?
    let customChallengeId: UUID?
    let caption: String?
    let photoPath: String
    let status: SubmissionStatus
    let pointsAwarded: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, caption, status
        case userId = "user_id"
        case challengeId = "challenge_id"
        case customChallengeId = "custom_challenge_id"
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
    let dareCustomChallengeId: UUID?
    let dareChallenge: DareChallengeRecord?
    let dareCustomChallenge: DareChallengeRecord?
    let createdAt: Date
    let profiles: ChatAuthorRecord?

    enum CodingKeys: String, CodingKey {
        case id, text
        case groupId = "group_id"
        case userId = "user_id"
        case isDare = "is_dare"
        case dareChallengeId = "dare_challenge_id"
        case dareCustomChallengeId = "dare_custom_challenge_id"
        case dareChallenge = "dare_challenge"
        case dareCustomChallenge = "dare_custom_challenge"
        case createdAt = "created_at"
        case profiles
    }
}

struct DareChallengeRecord: Codable {
    let points: Int?
}

struct ChatAuthorRecord: Codable, Hashable {
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

struct AdminSubmissionRecord: Decodable {
    let id: UUID
    let userId: UUID
    let challengeId: UUID?
    let customChallengeId: UUID?
    let caption: String?
    let photoPath: String
    let status: SubmissionStatus
    let createdAt: Date
    let profiles: AdminSubmitterProfile?
    let challenge: AdminDareInfo?
    let customChallenge: AdminDareInfo?

    enum CodingKeys: String, CodingKey {
        case id, caption, status
        case userId = "user_id"
        case challengeId = "challenge_id"
        case customChallengeId = "custom_challenge_id"
        case photoPath = "photo_path"
        case createdAt = "created_at"
        case profiles
        case challenge
        case customChallenge = "custom_challenge"
    }

    var asAdminSubmission: AdminSubmission {
        let dare = challenge ?? customChallenge
        return AdminSubmission(
            id: id,
            userId: userId,
            submitterName: profiles?.displayName ?? "Player",
            submitterHandle: profiles?.handle ?? "@player",
            submitterEmoji: profiles?.avatarEmoji ?? "🍳",
            dareTitle: dare?.text ?? "Dare",
            points: dare?.points,
            caption: caption,
            photoPath: photoPath,
            status: status,
            createdAt: createdAt
        )
    }
}

struct AdminSubmitterProfile: Decodable {
    let displayName: String
    let handle: String
    let avatarEmoji: String

    enum CodingKeys: String, CodingKey {
        case handle
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
    }
}

struct AdminDareInfo: Decodable {
    let text: String
    let points: Int?
}

struct SubmissionReviewPayload: Encodable {
    let status: String
    let reviewNote: String?
    let reviewedBy: UUID

    enum CodingKeys: String, CodingKey {
        case status
        case reviewNote = "review_note"
        case reviewedBy = "reviewed_by"
    }
}

struct NewSubmissionPayload: Encodable {
    let id: UUID
    let userId: UUID
    let challengeId: UUID?
    let customChallengeId: UUID?
    let groupId: UUID?
    let caption: String?
    let photoPath: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, caption, status
        case userId = "user_id"
        case challengeId = "challenge_id"
        case customChallengeId = "custom_challenge_id"
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
    let dareCustomChallengeId: UUID?

    enum CodingKeys: String, CodingKey {
        case text
        case groupId = "group_id"
        case userId = "user_id"
        case isDare = "is_dare"
        case dareChallengeId = "dare_challenge_id"
        case dareCustomChallengeId = "dare_custom_challenge_id"
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

struct BlockedUserRecord: Identifiable, Codable, Hashable {
    let blockerId: UUID
    let blockedId: UUID
    let createdAt: Date
    let blockedProfile: ChatAuthorRecord?

    var id: UUID { blockedId }

    enum CodingKeys: String, CodingKey {
        case blockerId = "blocker_id"
        case blockedId = "blocked_id"
        case createdAt = "created_at"
        case blockedProfile = "blocked_profile"
    }
}

struct UserReportPayload: Encodable {
    let reporterId: UUID
    let details: String
    let reportType: String
    let reportedUserId: UUID?
    let reportedMessageId: UUID?

    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case details
        case reportType = "report_type"
        case reportedUserId = "reported_user_id"
        case reportedMessageId = "reported_message_id"
    }
}

struct NewCustomChallengePayload: Encodable {
    let groupId: UUID
    let createdBy: UUID
    let text: String
    let points: Int

    enum CodingKeys: String, CodingKey {
        case text, points
        case groupId = "group_id"
        case createdBy = "created_by"
    }
}

struct CustomChallengeRecord: Decodable {
    let id: UUID
}
