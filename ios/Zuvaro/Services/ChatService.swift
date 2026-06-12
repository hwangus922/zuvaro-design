import Foundation
import Supabase

protocol ChatServiceProtocol {
    func fetchMessages(groupId: UUID, currentUserId: UUID) async throws -> [ChatMessage]
    func sendMessage(groupId: UUID, userId: UUID, text: String) async throws
    func sendDare(groupId: UUID, userId: UUID, text: String, challengeId: UUID?) async throws
    func sendCustomDare(groupId: UUID, userId: UUID, text: String, points: Int) async throws
}

@MainActor
final class LiveChatService: ChatServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchMessages(groupId: UUID, currentUserId: UUID) async throws -> [ChatMessage] {
        let records: [ChatMessageRecord] = try await client
            .from("chat_messages")
            .select("*, profiles(display_name, avatar_emoji), dare_challenge:challenges(points), dare_custom_challenge:custom_challenges(points)")
            .eq("group_id", value: groupId.uuidString)
            .order("created_at")
            .execute()
            .value

        return records.map { record in
            let author = record.profiles?.displayName ?? "Player"
            let emoji = record.profiles?.avatarEmoji ?? "🍳"
            let darePoints = record.dareChallenge?.points ?? record.dareCustomChallenge?.points
            return ChatMessage(
                id: record.id,
                userId: record.userId,
                author: author,
                emoji: emoji,
                text: record.text,
                time: Self.timeLabel(record.createdAt),
                isMe: record.userId == currentUserId,
                isDare: record.isDare,
                dareChallengeId: record.dareChallengeId,
                dareCustomChallengeId: record.dareCustomChallengeId,
                darePoints: darePoints
            )
        }
    }

    func sendMessage(groupId: UUID, userId: UUID, text: String) async throws {
        let payload = NewChatMessagePayload(
            groupId: groupId,
            userId: userId,
            text: text,
            isDare: false,
            dareChallengeId: nil,
            dareCustomChallengeId: nil
        )
        try await client.from("chat_messages").insert(payload).execute()
    }

    func sendDare(groupId: UUID, userId: UUID, text: String, challengeId: UUID?) async throws {
        let payload = NewChatMessagePayload(
            groupId: groupId,
            userId: userId,
            text: text,
            isDare: true,
            dareChallengeId: challengeId,
            dareCustomChallengeId: nil
        )
        try await client.from("chat_messages").insert(payload).execute()
    }

    func sendCustomDare(groupId: UUID, userId: UUID, text: String, points: Int) async throws {
        let createdChallenges: [CustomChallengeRecord] = try await client
            .from("custom_challenges")
            .insert(
                NewCustomChallengePayload(
                    groupId: groupId,
                    createdBy: userId,
                    text: text,
                    points: points
                )
            )
            .select("id")
            .execute()
            .value

        guard let customChallengeId = createdChallenges.first?.id else {
            throw ChatServiceError.customDareCreateFailed
        }

        let payload = NewChatMessagePayload(
            groupId: groupId,
            userId: userId,
            text: "\(text) (+\(points)pts)",
            isDare: true,
            dareChallengeId: nil,
            dareCustomChallengeId: customChallengeId
        )
        try await client.from("chat_messages").insert(payload).execute()
    }

    private static func timeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum ChatServiceError: LocalizedError {
    case customDareCreateFailed

    var errorDescription: String? {
        switch self {
        case .customDareCreateFailed: return "Could not create custom dare."
        }
    }
}

@MainActor
final class MockChatService: ChatServiceProtocol {
    func fetchMessages(groupId: UUID, currentUserId: UUID) async throws -> [ChatMessage] {
        MockData.chatMessages
    }

    func sendMessage(groupId: UUID, userId: UUID, text: String) async throws {}

    func sendDare(groupId: UUID, userId: UUID, text: String, challengeId: UUID?) async throws {}

    func sendCustomDare(groupId: UUID, userId: UUID, text: String, points: Int) async throws {}
}
