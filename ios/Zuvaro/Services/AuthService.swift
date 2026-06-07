import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var session: Session?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var currentNonce: String?
    private let client: SupabaseClient?

    init(client: SupabaseClient? = SupabaseManager.shared) {
        self.client = client
    }

    var isSignedIn: Bool { session != nil }

    func bootstrap() async {
        guard let client else { return }
        session = try? await client.auth.session
        for await change in client.auth.authStateChanges {
            session = change.session
        }
    }

    func signInWithApple(_ result: Result<ASAuthorization, Error>) async {
        guard let client else {
            errorMessage = "Backend not configured. Add Supabase keys in Secrets.xcconfig."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let authorization = try result.get()
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                throw AuthServiceError.invalidAppleCredential
            }

            session = try await client.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            ).session
        } catch {
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return }
            errorMessage = error.localizedDescription
        }
    }

    func prepareAppleSignIn() -> String {
        let nonce = randomNonce()
        currentNonce = nonce
        return sha256(nonce)
    }

    func signIn(email: String, password: String) async {
        await authenticate(email: email, password: password, signUp: false)
    }

    func signUp(email: String, password: String, displayName: String?) async {
        await authenticate(
            email: email,
            password: password,
            signUp: true,
            metadata: displayName.map { ["full_name": $0] } ?? [:]
        )
    }

    func signOut() async {
        guard let client else { return }
        try? await client.auth.signOut()
        session = nil
    }

    func deleteAccount() async {
        guard let client, let userID = session?.user.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await client.from("profiles").delete().eq("id", value: userID.uuidString).execute()
            try await client.auth.signOut()
            session = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func authenticate(
        email: String,
        password: String,
        signUp: Bool,
        metadata: [String: AnyJSON] = [:]
    ) async {
        guard let client else {
            errorMessage = "Backend not configured. Add Supabase keys in Secrets.xcconfig."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if signUp {
                session = try await client.auth.signUp(
                    email: email,
                    password: password,
                    data: metadata
                ).session
            } else {
                session = try await client.auth.signIn(
                    email: email,
                    password: password
                ).session
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func randomNonce(length: Int = 32) -> String {
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

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum AuthServiceError: LocalizedError {
    case invalidAppleCredential

    var errorDescription: String? {
        switch self {
        case .invalidAppleCredential: "Sign in with Apple failed. Try again."
        }
    }
}
