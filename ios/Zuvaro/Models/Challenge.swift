import Foundation

struct Sponsor: Identifiable, Hashable, Codable {
    let id: UUID?
    let name: String
    let tagline: String?
    let logoEmoji: String
    let websiteURL: String?

    var isSponsored: Bool { id != nil || !name.isEmpty }

    enum CodingKeys: String, CodingKey {
        case id, name, tagline
        case logoEmoji = "logo_emoji"
        case websiteURL = "website_url"
    }
}

struct PrizePool: Identifiable, Hashable, Codable {
    let id: UUID
    let regionId: UUID
    let title: String
    let totalCents: Int
    let currency: String
    let periodEnd: Date

    /// Top 5 split: 40% / 25% / 15% / 12% / 8%
    static let topFiveSplit: [Double] = [0.40, 0.25, 0.15, 0.12, 0.08]

    enum CodingKeys: String, CodingKey {
        case id, title, currency
        case regionId = "region_id"
        case totalCents = "total_cents"
        case periodEnd = "period_end"
    }

    func estimatedPayoutCents(for rank: Int) -> Int? {
        guard rank >= 1, rank <= Self.topFiveSplit.count else { return nil }
        let share = Self.topFiveSplit[rank - 1]
        return Int((Double(totalCents) * share).rounded())
    }

    var formattedTotal: String {
        PrizePool.formatCents(totalCents, currency: currency)
    }

    var refreshLabel: String {
        let remaining = max(0, periodEnd.timeIntervalSinceNow)
        let hours = Int(remaining) / 3600
        if hours >= 24 {
            let days = hours / 24
            return "pays out in \(days)d"
        }
        if hours >= 1 {
            return "pays out in \(hours)h"
        }
        let minutes = max(1, Int(remaining) / 60)
        return "pays out in \(minutes)m"
    }

    static func formatCents(_ cents: Int, currency: String = "usd") -> String {
        let amount = Double(cents) / 100.0
        if currency.lowercased() == "usd" {
            if amount.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "$%.0f", amount)
            }
            return String(format: "$%.2f", amount)
        }
        return String(format: "%.2f %@", amount, currency.uppercased())
    }
}

struct Challenge: Identifiable, Hashable, Codable {
    let id: UUID
    let time: String
    let text: String
    let points: Int?
    let hook: String
    let minutes: Int
    let rules: String
    var sponsor: Sponsor?
    var isCustomChallenge: Bool = false

    var isSponsored: Bool { sponsor?.isSponsored == true }

    var pointsLabel: String {
        if let points { return "+\(points)pts" }
        return "for the lulz"
    }

    var sponsorLabel: String? {
        guard let sponsor, sponsor.isSponsored else { return nil }
        return "Sponsored · \(sponsor.name)"
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
    var estimatedPayoutCents: Int?

    var estimatedPayoutLabel: String? {
        guard let estimatedPayoutCents else { return nil }
        return PrizePool.formatCents(estimatedPayoutCents)
    }

    func withPayout(from pool: PrizePool?) -> LeaderboardEntry {
        var copy = self
        copy.estimatedPayoutCents = pool?.estimatedPayoutCents(for: rank)
        return copy
    }
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
