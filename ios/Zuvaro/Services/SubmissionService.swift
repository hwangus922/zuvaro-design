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

        let challengeMap = try await challengeTitleMap(for: records.map(\.challengeId))
        return records.map { record in
            Submission(
                id: record.id,
                challengeId: record.challengeId,
                dareTitle: challengeMap[record.challengeId] ?? "Dare",
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
        let path = "\(userId.uuidString)/\(submissionId.uuidString).jpg"

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
            challengeId: challenge.id,
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
            challengeId: record.challengeId,
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
        let title = try await challengeTitleMap(for: [record.challengeId])[record.challengeId] ?? "Dare"
        return Submission(
            id: record.id,
            challengeId: record.challengeId,
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
}
