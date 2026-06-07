import Foundation
import Supabase

protocol NotificationServiceProtocol {
    func fetchNotifications(userId: UUID) async throws -> [AppNotification]
    func markAllRead(userId: UUID) async throws
}

@MainActor
final class LiveNotificationService: NotificationServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchNotifications(userId: UUID) async throws -> [AppNotification] {
        let records: [NotificationRecord] = try await client
            .from("notifications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return records.map { record in
            AppNotification(
                id: record.id,
                title: record.title,
                body: record.body,
                time: Self.relativeTime(record.createdAt),
                unread: record.unread,
                kind: Self.kind(from: record.kind)
            )
        }
    }

    func markAllRead(userId: UUID) async throws {
        try await client
            .from("notifications")
            .update(["unread": false])
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    private static func kind(from raw: String) -> AppNotification.Kind {
        switch raw {
        case "dare": return .dare
        case "board": return .board
        case "friend": return .friend
        default: return .proof
        }
    }

    private static func relativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

@MainActor
final class MockNotificationService: NotificationServiceProtocol {
    func fetchNotifications(userId: UUID) async throws -> [AppNotification] {
        MockData.notifications
    }

    func markAllRead(userId: UUID) async throws {}
}
