import Foundation

struct Challenge: Identifiable, Hashable, Codable {
    let id: UUID
    let time: String
    let text: String
    let points: Int?
    let hook: String
    let minutes: Int
    let rules: String
    var isCustomChallenge: Bool = false

    var pointsLabel: String {
        if let points { return "+\(points)pts" }
        return "for the lulz"
    }
}

enum SubmissionStatus: String, Codable, Hashable {
    case pending
    case approved
    case rejected
}

struct Submission: Identifiable, Hashable {
    let id: UUID
    let challengeId: UUID
    let dareTitle: String
    let status: SubmissionStatus
    let points: Int?
    let createdAt: Date

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct AdminSubmission: Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let submitterName: String
    let submitterHandle: String
    let submitterEmoji: String
    let dareTitle: String
    let points: Int?
    let caption: String?
    let photoPath: String
    let status: SubmissionStatus
    let createdAt: Date

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

struct LeaderboardEntry: Identifiable, Hashable {
    let id: UUID
    let rank: Int
    let name: String
    let handle: String
    let points: Int
    let emoji: String
    var isMe: Bool = false
}

struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let author: String
    let emoji: String
    let text: String
    let time: String
    var isMe: Bool = false
    var isDare: Bool = false
    var dareChallengeId: UUID?
    var dareCustomChallengeId: UUID?
    var darePoints: Int?
}

struct AppNotification: Identifiable, Hashable {
    let id: UUID
    let title: String
    let body: String
    let time: String
    let unread: Bool
    let kind: Kind

    enum Kind: Hashable {
        case proof, dare, board, friend
    }
}
