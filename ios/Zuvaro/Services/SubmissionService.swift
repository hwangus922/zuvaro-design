import Foundation
import Supabase

struct ChallengeTitleRecord: Decodable {
    let id: UUID
    let text: String
}

protocol SubmissionServiceProtocol {
    func fetchMySubmissions(userId: UUID) async throws -> [Submission]
    func submitProof(
        userId: UUID,
        challenge: Challenge,
        groupId: UUID?,
        imageData: Data,
        caption: String?
    ) async throws -> Submission
    func fetchSubmission(id: UUID) async throws -> Submission?
    func fetchAdminSubmissions(status: SubmissionStatus?) async throws -> [AdminSubmission]
    func reviewSubmission(id: UUID, reviewerId: UUID, status: SubmissionStatus, reviewNote: String?) async throws
    func downloadProofPhoto(path: String) async throws -> Data
}

@MainActor
final class LiveSubmissionService: SubmissionServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchMySubmissions(userId: UUID) async throws -> [Submission] {
        let records: [SubmissionRecord] = try await client
            .from("submissions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        let challengeMap = try await challengeTitleMap(for: records.compactMap(\.challengeId))
        let customMap = try await customChallengeTitleMap(for: records.compactMap(\.customChallengeId))
        return records.map { record in
            let dareTitle: String
            let challengeId: UUID
            if let catalogId = record.challengeId {
                dareTitle = challengeMap[catalogId] ?? "Dare"
                challengeId = catalogId
            } else if let customId = record.customChallengeId {
                dareTitle = customMap[customId] ?? "Custom dare"
                challengeId = customId
            } else {
                dareTitle = "Dare"
                challengeId = record.id
            }
            return Submission(
                id: record.id,
                challengeId: challengeId,
                dareTitle: dareTitle,
                status: record.status,
                points: record.pointsAwarded,
                createdAt: record.createdAt
            )
        }
    }

    func submitProof(
        userId: UUID,
        challenge: Challenge,
        groupId: UUID?,
        imageData: Data,
        caption: String?
    ) async throws -> Submission {
        let submissionId = UUID()
        // Storage RLS compares folder name to auth.uid()::text (lowercase).
        let path = "\(userId.uuidString.lowercased())/\(submissionId.uuidString.lowercased()).jpg"

        try await client.storage
            .from("proofs")
            .upload(
                path,
                data: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )

        let payload = NewSubmissionPayload(
            id: submissionId,
            userId: userId,
            challengeId: challenge.isCustomChallenge ? nil : challenge.id,
            customChallengeId: challenge.isCustomChallenge ? challenge.id : nil,
            groupId: groupId,
            caption: caption?.isEmpty == true ? nil : caption,
            photoPath: path,
            status: SubmissionStatus.pending.rawValue
        )

        let records: [SubmissionRecord] = try await client
            .from("submissions")
            .insert(payload)
            .select()
            .execute()
            .value

        guard let record = records.first else {
            throw SubmissionServiceError.createFailed
        }

        return Submission(
            id: record.id,
            challengeId: challenge.id,
            dareTitle: challenge.text,
            status: record.status,
            points: record.pointsAwarded,
            createdAt: record.createdAt
        )
    }

    func fetchSubmission(id: UUID) async throws -> Submission? {
        let records: [SubmissionRecord] = try await client
            .from("submissions")
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value
        guard let record = records.first else { return nil }
        let title: String
        if let catalogId = record.challengeId {
            title = try await challengeTitleMap(for: [catalogId])[catalogId] ?? "Dare"
        } else if let customId = record.customChallengeId {
            title = try await customChallengeTitleMap(for: [customId])[customId] ?? "Custom dare"
        } else {
            title = "Dare"
        }
        return Submission(
            id: record.id,
            challengeId: record.challengeId ?? record.customChallengeId ?? record.id,
            dareTitle: title,
            status: record.status,
            points: record.pointsAwarded,
            createdAt: record.createdAt
        )
    }

    private func challengeTitleMap(for ids: [UUID]) async throws -> [UUID: String] {
        guard !ids.isEmpty else { return [:] }
        let unique = Array(Set(ids))
        let records: [ChallengeTitleRecord] = try await client
            .from("challenges")
            .select("id,text")
            .in("id", values: unique.map(\.uuidString))
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0.text) })
    }

    private func customChallengeTitleMap(for ids: [UUID]) async throws -> [UUID: String] {
        guard !ids.isEmpty else { return [:] }
        let unique = Array(Set(ids))
        let records: [ChallengeTitleRecord] = try await client
            .from("custom_challenges")
            .select("id,text")
            .in("id", values: unique.map(\.uuidString))
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0.text) })
    }

    func fetchAdminSubmissions(status: SubmissionStatus?) async throws -> [AdminSubmission] {
        let select = "*, profiles:profiles!submissions_user_id_fkey(display_name, handle, avatar_emoji), challenge:challenges!submissions_challenge_id_fkey(text, points), custom_challenge:custom_challenges!submissions_custom_challenge_id_fkey(text, points)"
        let records: [AdminSubmissionRecord]
        if let status {
            records = try await client
                .from("submissions")
                .select(select)
                .eq("status", value: status.rawValue)
                .order("created_at", ascending: false)
                .execute()
                .value
        } else {
            records = try await client
                .from("submissions")
                .select(select)
                .order("created_at", ascending: false)
                .execute()
                .value
        }
        return records.map(\.asAdminSubmission)
    }

    func reviewSubmission(id: UUID, reviewerId: UUID, status: SubmissionStatus, reviewNote: String?) async throws {
        let payload = SubmissionReviewPayload(
            status: status.rawValue,
            reviewNote: reviewNote,
            reviewedBy: reviewerId
        )
        try await client
            .from("submissions")
            .update(payload)
            .eq("id", value: id.uuidString)
            .execute()
    }

    func downloadProofPhoto(path: String) async throws -> Data {
        try await client.storage
            .from("proofs")
            .download(path: path)
    }
}

enum SubmissionServiceError: LocalizedError {
    case createFailed

    var errorDescription: String? {
        switch self {
        case .createFailed: return "Could not create submission."
        }
    }
}

@MainActor
final class MockSubmissionService: SubmissionServiceProtocol {
    private var stored = MockData.submissions

    func fetchMySubmissions(userId: UUID) async throws -> [Submission] { stored }

    func submitProof(
        userId: UUID,
        challenge: Challenge,
        groupId: UUID?,
        imageData: Data,
        caption: String?
    ) async throws -> Submission {
        let submission = Submission(
            id: UUID(),
            challengeId: challenge.id,
            dareTitle: challenge.text,
            status: .pending,
            points: challenge.points,
            createdAt: Date()
        )
        stored.insert(submission, at: 0)
        return submission
    }

    func fetchSubmission(id: UUID) async throws -> Submission? {
        stored.first { $0.id == id }
    }

    func fetchAdminSubmissions(status: SubmissionStatus?) async throws -> [AdminSubmission] {
        let pending = AdminSubmission(
            id: UUID(),
            userId: UUID(),
            submitterName: "Alex",
            submitterHandle: "@alex",
            submitterEmoji: "🐺",
            dareTitle: "Give a genuine compliment",
            points: 15,
            caption: "Done fr",
            photoPath: "mock/photo.jpg",
            status: .pending,
            createdAt: Date().addingTimeInterval(-3600)
        )
        guard status == nil || status == .pending else { return [] }
        return [pending]
    }

    func reviewSubmission(id: UUID, reviewerId: UUID, status: SubmissionStatus, reviewNote: String?) async throws {
        _ = id
        _ = reviewerId
        _ = status
        _ = reviewNote
    }

    func downloadProofPhoto(path: String) async throws -> Data {
        _ = path
        return Data()
    }
}
