import Foundation
import Supabase

protocol LeaderboardServiceProtocol {
    func fetchFriendsBoard(groupId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry]
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
}

@MainActor
final class MockLeaderboardService: LeaderboardServiceProtocol {
    func fetchFriendsBoard(groupId: UUID, currentUserId: UUID) async throws -> [LeaderboardEntry] {
        MockData.friendsBoard
    }
}
