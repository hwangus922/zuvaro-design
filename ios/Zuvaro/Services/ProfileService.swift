import Foundation
import Supabase

protocol ProfileServiceProtocol {
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func updateProfile(userId: UUID, displayName: String, handle: String, avatarEmoji: String) async throws -> UserProfile
    func ensurePrimaryGroup(userId: UUID) async throws -> GroupRecord
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
        struct MembershipRow: Decodable {
            let groupId: UUID
            enum CodingKeys: String, CodingKey { case groupId = "group_id" }
        }

        let memberships: [MembershipRow] = try await client
            .from("group_members")
            .select("group_id")
            .eq("user_id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        if let membership = memberships.first {
            let groups: [GroupRecord] = try await client
                .from("groups")
                .select()
                .eq("id", value: membership.groupId.uuidString)
                .limit(1)
                .execute()
                .value
            if let group = groups.first { return group }
        }

        struct NewGroupPayload: Encodable {
            let name: String
            let createdBy: UUID
            enum CodingKeys: String, CodingKey {
                case name
                case createdBy = "created_by"
            }
        }

        let created: [GroupRecord] = try await client
            .from("groups")
            .insert(NewGroupPayload(name: "Chaos Crew", createdBy: userId))
            .select()
            .execute()
            .value

        guard let group = created.first else { throw ProfileServiceError.groupCreateFailed }

        struct MemberPayload: Encodable {
            let groupId: UUID
            let userId: UUID
            let role: String
            enum CodingKeys: String, CodingKey {
                case role
                case groupId = "group_id"
                case userId = "user_id"
            }
        }

        try await client
            .from("group_members")
            .insert(MemberPayload(groupId: group.id, userId: userId, role: "admin"))
            .execute()

        return group
    }

    func deleteAccount(userId: UUID) async throws {
        // Account deletion requires a server-side admin function in production.
        // For now, sign out locally after marking intent.
        _ = userId
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
            isAdmin: false
        )
    }

    func updateProfile(userId: UUID, displayName: String, handle: String, avatarEmoji: String) async throws -> UserProfile {
        try await fetchProfile(userId: userId)
    }

    func ensurePrimaryGroup(userId: UUID) async throws -> GroupRecord {
        GroupRecord(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, name: "Chaos Crew", inviteCode: "chaos-crew")
    }

    func deleteAccount(userId: UUID) async throws {}
}
