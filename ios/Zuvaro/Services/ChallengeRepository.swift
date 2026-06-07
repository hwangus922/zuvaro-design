import Foundation
import Supabase

protocol ChallengeRepositoryProtocol {
    func fetchActiveChallenges() async throws -> [Challenge]
}

@MainActor
final class LiveChallengeRepository: ChallengeRepositoryProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchActiveChallenges() async throws -> [Challenge] {
        let records: [ChallengeRecord] = try await client
            .from("challenges")
            .select()
            .eq("is_active", value: true)
            .order("sort_order")
            .execute()
            .value
        return records.map(\.asChallenge)
    }
}

@MainActor
final class MockChallengeRepository: ChallengeRepositoryProtocol {
    func fetchActiveChallenges() async throws -> [Challenge] {
        MockData.challenges
    }
}
