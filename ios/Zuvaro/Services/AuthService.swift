import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

protocol AuthServiceProtocol {
    var currentUserId: UUID? { get }
    func restoreSession() async throws -> UUID?
    func signUp(email: String, password: String) async throws -> UUID
    func signIn(email: String, password: String) async throws -> UUID
    func signInWithApple(idToken: String, nonce: String) async throws -> UUID
    func signOut() async throws
}

enum AuthServiceError: LocalizedError {
    case notConfigured
    case missingSession
    case invalidCredential

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Supabase is not configured."
        case .missingSession: return "No active session."
        case .invalidCredential: return "Invalid sign-in credentials."
        }
    }
}

enum AppleSignInSupport {
    static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remaining == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

@MainActor
final class LiveAuthService: AuthServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    var currentUserId: UUID? {
        client.auth.currentUser.flatMap { UUID(uuidString: $0.id.uuidString) }
    }

    func restoreSession() async throws -> UUID? {
        _ = try await client.auth.session
        return currentUserId
    }

    func signUp(email: String, password: String) async throws -> UUID {
        let response = try await client.auth.signUp(email: email, password: password)
        guard let user = response.user, let id = UUID(uuidString: user.id.uuidString) else {
            throw AuthServiceError.missingSession
        }
        return id
    }

    func signIn(email: String, password: String) async throws -> UUID {
        let session = try await client.auth.signIn(email: email, password: password)
        guard let id = UUID(uuidString: session.user.id.uuidString) else {
            throw AuthServiceError.invalidCredential
        }
        return id
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> UUID {
        let session = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce)
        )
        guard let id = UUID(uuidString: session.user.id.uuidString) else {
            throw AuthServiceError.invalidCredential
        }
        return id
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}

@MainActor
final class MockAuthService: AuthServiceProtocol {
    private(set) var currentUserId: UUID? = UUID(uuidString: "00000000-0000-0000-0000-000000000099")

    func restoreSession() async throws -> UUID? { currentUserId }

    func signUp(email: String, password: String) async throws -> UUID {
        currentUserId = UUID()
        return currentUserId!
    }

    func signIn(email: String, password: String) async throws -> UUID {
        guard !password.isEmpty else { throw AuthServiceError.invalidCredential }
        return currentUserId!
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> UUID {
        currentUserId = UUID()
        return currentUserId!
    }

    func signOut() async throws {
        currentUserId = nil
    }
}
