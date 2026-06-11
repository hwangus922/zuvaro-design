import Foundation
import Supabase

protocol LeaderboardServiceProtocol {
    func fetchFriendsBoard(groupId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry]
    func fetchRegionalBoard(regionId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry]
    func fetchGlobalBoard(currentUserId: UUID) async throws -> [LeaderboardEntry]
    func fetchActivePrizePool(regionId: UUID) async throws -> PrizePool?
}

@MainActor
final class LiveLeaderboardService: LeaderboardServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchFriendsBoard(groupId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry] {
        let records: [LeaderboardRecord] = try await client
            .from("friends_leaderboard")
            .select()
            .eq("group_id", value: groupId.uuidString)
            .order("rank")
            .execute()
            .value

        return records.map { record in
            LeaderboardEntry(
                id: record.userId,
                rank: record.rank,
                name: record.displayName,
                handle: record.handle,
                points: record.totalPoints,
                emoji: record.avatarEmoji,
                isMe: record.userId == currentUserId
            )
        }
    }

    func fetchRegionalBoard(regionId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry] {
        let records: [RegionalLeaderboardRecord] = try await client
            .from("regional_leaderboard")
            .select()
            .eq("region_id", value: regionId.uuidString)
            .order("rank")
            .limit(50)
            .execute()
            .value

        return records.map { record in
            LeaderboardEntry(
                id: record.userId,
                rank: record.rank,
                name: record.displayName,
                handle: record.handle,
                points: record.totalPoints,
                emoji: record.avatarEmoji,
                isMe: record.userId == currentUserId
            )
        }
    }

    func fetchGlobalBoard(currentUserId: UUID) async throws -> [LeaderboardEntry] {
        let records: [GlobalLeaderboardRecord] = try await client
            .from("profiles")
            .select("id, display_name, handle, avatar_emoji, total_points")
            .order("total_points", ascending: false)
            .limit(50)
            .execute()
            .value

        return records.enumerated().map { index, record in
            LeaderboardEntry(
                id: record.id,
                rank: index + 1,
                name: record.displayName,
                handle: record.handle,
                points: record.totalPoints,
                emoji: record.avatarEmoji,
                isMe: record.id == currentUserId
            )
        }
    }

    func fetchActivePrizePool(regionId: UUID) async throws -> PrizePool? {
        let pools: [PrizePool] = try await client
            .from("prize_pools")
            .select()
            .eq("region_id", value: regionId.uuidString)
            .eq("status", value: "active")
            .order("period_end", ascending: true)
            .limit(3)
            .execute()
            .value
        return pools.first { $0.periodEnd > Date() }
    }
}

struct RegionalLeaderboardRecord: Codable {
    let regionId: UUID
    let userId: UUID
    let displayName: String
    let handle: String
    let avatarEmoji: String
    let totalPoints: Int
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case rank, handle
        case regionId = "region_id"
        case userId = "user_id"
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
        case totalPoints = "total_points"
    }
}

struct GlobalLeaderboardRecord: Codable {
    let id: UUID
    let displayName: String
    let handle: String
    let avatarEmoji: String
    let totalPoints: Int

    enum CodingKeys: String, CodingKey {
        case id, handle
        case displayName = "display_name"
        case avatarEmoji = "avatar_emoji"
        case totalPoints = "total_points"
    }
}

@MainActor
final class MockLeaderboardService: LeaderboardServiceProtocol {
    func fetchFriendsBoard(groupId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry] {
        MockData.friendsBoard
    }

    func fetchRegionalBoard(regionId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry] {
        _ = regionId
        return MockData.friendsBoard
    }

    func fetchGlobalBoard(currentUserId: UUID) async throws -> [LeaderboardEntry] {
        MockData.friendsBoard
    }

    func fetchActivePrizePool(regionId: UUID) async throws -> PrizePool? {
        _ = regionId
        return MockData.prizePool
    }
}
