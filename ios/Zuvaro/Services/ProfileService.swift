import Foundation
import Supabase

protocol ProfileServiceProtocol {
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func updateProfile(userId: UUID, displayName: String, handle: String, avatarEmoji: String) async throws -> UserProfile
    func ensurePrimaryGroup(userId: UUID) async throws -> GroupRecord
    func joinGroup(inviteCode: String) async throws -> GroupRecord
    func fetchRegions() async throws -> [Region]
    func setRegion(code: String) async throws -> UserProfile
    func setUsername(_ username: String) async throws -> UserProfile
    func isUsernameAvailable(_ username: String) async throws -> Bool
    func deleteAccount(userId: UUID) async throws
}

@MainActor
final class LiveProfileService: ProfileServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        let profiles: [UserProfile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        guard let profile = profiles.first else {
            throw ProfileServiceError.notFound
        }
        return profile
    }

    func updateProfile(userId: UUID, displayName: String, handle: String, avatarEmoji: String) async throws -> UserProfile {
        let payload = ProfileUpdatePayload(displayName: displayName, handle: handle, avatarEmoji: avatarEmoji)
        let profiles: [UserProfile] = try await client
            .from("profiles")
            .update(payload)
            .eq("id", value: userId.uuidString)
            .select()
            .execute()
            .value
        guard let profile = profiles.first else { throw ProfileServiceError.notFound }
        return profile
    }

    func ensurePrimaryGroup(userId: UUID) async throws -> GroupRecord {
        _ = userId
        return try await client
            .rpc("ensure_primary_group", params: ["group_name": "Chaos Crew"])
            .execute()
            .value
    }

    func joinGroup(inviteCode: String) async throws -> GroupRecord {
        return try await client
            .rpc("join_group_by_invite", params: ["p_invite_code": inviteCode])
            .execute()
            .value
    }

    func fetchRegions() async throws -> [Region] {
        try await client
            .from("regions")
            .select()
            .order("sort_order")
            .execute()
            .value
    }

    func setRegion(code: String) async throws -> UserProfile {
        try await client
            .rpc("set_user_region", params: ["p_region_code": code])
            .execute()
            .value
    }

    func setUsername(_ username: String) async throws -> UserProfile {
        try await client
            .rpc("set_username", params: ["p_username": username])
            .execute()
            .value
    }

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        try await client
            .rpc("check_username_available", params: ["p_username": username])
            .execute()
            .value
    }

    func deleteAccount(userId: UUID) async throws {
        _ = userId
        try await client.rpc("delete_my_account").execute()
    }
}

enum ProfileServiceError: LocalizedError {
    case notFound
    case groupCreateFailed

    var errorDescription: String? {
        switch self {
        case .notFound: return "Profile not found."
        case .groupCreateFailed: return "Could not create your group."
        }
    }
}

@MainActor
final class MockProfileService: ProfileServiceProtocol {
    func fetchProfile(userId: UUID) async throws -> UserProfile {
        UserProfile(
            id: userId,
            displayName: "John Winner",
            handle: "@IloveMyGTA6too",
            avatarEmoji: "👑",
            totalPoints: 70,
            questDone: 1,
            questTotal: 5,
            wins: 47,
            longestStreak: 23,
            challengesCompleted: 184,
            isAdmin: false,
            regionId: UUID(uuidString: "00000000-0000-0000-0000-000000000020"),
            referralCount: 2,
            referralBonusClaimed: false,
            usernameCustomized: true
        )
    }

    func setUsername(_ username: String) async throws -> UserProfile {
        var profile = try await fetchProfile(userId: UUID())
        profile.handle = UsernameValidator.handle(for: username)
        profile.usernameCustomized = true
        return profile
    }

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let normalized = UsernameValidator.normalize(username)
        return normalized != "taken"
    }

    func updateProfile(userId: UUID, displayName: String, handle: String, avatarEmoji: String) async throws -> UserProfile {
        try await fetchProfile(userId: userId)
    }

    func ensurePrimaryGroup(userId: UUID) async throws -> GroupRecord {
        GroupRecord(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, name: "Chaos Crew", inviteCode: "chaos-crew")
    }

    func joinGroup(inviteCode: String) async throws -> GroupRecord {
        _ = inviteCode
        return try await ensurePrimaryGroup(userId: UUID())
    }

    func fetchRegions() async throws -> [Region] {
        MockData.regions
    }

    func setRegion(code: String) async throws -> UserProfile {
        _ = code
        return try await fetchProfile(userId: UUID())
    }

    func deleteAccount(userId: UUID) async throws {}
}

protocol SafetyServiceProtocol {
    func fetchBlockedUsers(userId: UUID) async throws -> [BlockedUserRecord]
    func block(userId: UUID, blockedUserId: UUID) async throws
    func unblock(userId: UUID, blockedUserId: UUID) async throws
    func reportIssue(
        userId: UUID,
        details: String,
        reportedUserId: UUID?,
        reportedMessageId: UUID?,
        reportType: String
    ) async throws
}

@MainActor
final class LiveSafetyService: SafetyServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchBlockedUsers(userId: UUID) async throws -> [BlockedUserRecord] {
        try await client
            .from("blocked_users")
            .select("blocker_id, blocked_id, created_at, blocked_profile:profiles!blocked_users_blocked_id_fkey(display_name, avatar_emoji)")
            .eq("blocker_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func block(userId: UUID, blockedUserId: UUID) async throws {
        try await client
            .from("blocked_users")
            .insert(["blocker_id": userId.uuidString, "blocked_id": blockedUserId.uuidString])
            .execute()
    }

    func unblock(userId: UUID, blockedUserId: UUID) async throws {
        try await client
            .from("blocked_users")
            .delete()
            .eq("blocker_id", value: userId.uuidString)
            .eq("blocked_id", value: blockedUserId.uuidString)
            .execute()
    }

    func reportIssue(
        userId: UUID,
        details: String,
        reportedUserId: UUID? = nil,
        reportedMessageId: UUID? = nil,
        reportType: String = "support"
    ) async throws {
        let payload = UserReportPayload(
            reporterId: userId,
            details: details,
            reportType: reportType,
            reportedUserId: reportedUserId,
            reportedMessageId: reportedMessageId
        )
        try await client
            .from("user_reports")
            .insert(payload)
            .execute()
    }
}

@MainActor
final class MockSafetyService: SafetyServiceProtocol {
    func fetchBlockedUsers(userId: UUID) async throws -> [BlockedUserRecord] {
        _ = userId
        return [
            BlockedUserRecord(
                blockerId: UUID(),
                blockedId: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
                createdAt: Date(),
                blockedProfile: ChatAuthorRecord(displayName: "Spam Bot 3000", avatarEmoji: "🤖")
            ),
            BlockedUserRecord(
                blockerId: UUID(),
                blockedId: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
                createdAt: Date(),
                blockedProfile: ChatAuthorRecord(displayName: "Toxic Tim", avatarEmoji: "😤")
            )
        ]
    }

    func unblock(userId: UUID, blockedUserId: UUID) async throws {
        _ = userId
        _ = blockedUserId
    }

    func block(userId: UUID, blockedUserId: UUID) async throws {
        _ = userId
        _ = blockedUserId
    }

    func reportIssue(
        userId: UUID,
        details: String,
        reportedUserId: UUID? = nil,
        reportedMessageId: UUID? = nil,
        reportType: String = "support"
    ) async throws {
        _ = userId
        _ = details
        _ = reportedUserId
        _ = reportedMessageId
        _ = reportType
    }
}
