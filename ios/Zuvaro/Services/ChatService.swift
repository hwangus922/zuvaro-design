import Foundation
import Supabase

protocol ChatServiceProtocol {
    func fetchMessages(groupId: UUID, currentUserId: UUID) async throws -> [ChatMessage]
    func sendMessage(groupId: UUID, userId: UUID, text: String) async throws
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
            .select("*, profiles(display_name, avatar_emoji)")
            .eq("group_id", value: groupId.uuidString)
            .order("created_at")
            .execute()
            .value

        return records.map { record in
            let author = record.profiles?.displayName ?? "Player"
            let emoji = record.profiles?.avatarEmoji ?? "🍳"
            var darePoints: Int?
            if record.isDare, let dareId = record.dareChallengeId {
                darePoints = nil
                _ = dareId
            }
            return ChatMessage(
                id: record.id,
                author: author,
                emoji: emoji,
                text: record.text,
                time: Self.timeLabel(record.createdAt),
                isMe: record.userId == currentUserId,
                isDare: record.isDare,
                dareChallengeId: record.dareChallengeId,
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
            dareChallengeId: nil
        )
        try await client.from("chat_messages").insert(payload).execute()
    }

    private static func timeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

@MainActor
final class MockChatService: ChatServiceProtocol {
    func fetchMessages(groupId: UUID, currentUserId: UUID) async throws -> [ChatMessage] {
        MockData.chatMessages
    }

    func sendMessage(groupId: UUID, userId: UUID, text: String) async throws {}
}
