import Foundation
import Supabase

struct ContactFriendMatch: Identifiable, Hashable, Codable {
    let userId: UUID
    let displayName: String
    let handle: String
    let avatarEmoji: String

    var id: UUID { userId }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case handle
        case avatarEmoji = "avatar_emoji"
    }
}

struct PhoneVerificationResponse: Decodable {
    let phoneE164: String
    let expiresInSeconds: Int

    enum CodingKeys: String, CodingKey {
        case phoneE164 = "phone_e164"
        case expiresInSeconds = "expires_in_seconds"
    }
}

protocol PhoneServiceProtocol {
    func requestVerification(phone: String) async throws -> PhoneVerificationResponse
    func verifyCode(_ code: String) async throws -> UserProfile
    func updatePreferences(discoverable: Bool, smsEnabled: Bool) async throws -> UserProfile
    func findFriends(phoneNumbers: [String]) async throws -> [ContactFriendMatch]
    func removePhone() async throws -> UserProfile
}

@MainActor
final class LivePhoneService: PhoneServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func requestVerification(phone: String) async throws -> PhoneVerificationResponse {
        try await client
            .rpc("request_phone_verification", params: ["p_phone": phone])
            .execute()
            .value
    }

    func verifyCode(_ code: String) async throws -> UserProfile {
        try await client
            .rpc("verify_phone_code", params: ["p_code": code.trimmingCharacters(in: .whitespacesAndNewlines)])
            .execute()
            .value
    }

    func updatePreferences(discoverable: Bool, smsEnabled: Bool) async throws -> UserProfile {
        try await client
            .rpc(
                "set_phone_preferences",
                params: [
                    "p_discoverable": discoverable,
                    "p_sms_enabled": smsEnabled
                ]
            )
            .execute()
            .value
    }

    func findFriends(phoneNumbers: [String]) async throws -> [ContactFriendMatch] {
        try await client
            .rpc("find_friends_by_phones", params: ["p_phones": phoneNumbers])
            .execute()
            .value
    }

    func removePhone() async throws -> UserProfile {
        try await client.rpc("remove_phone_number").execute().value
    }
}

enum PhoneServiceError: LocalizedError {
    case notAuthenticated
    case notFound
    case invalidPhone

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Sign in to manage your phone number."
        case .notFound: return "Profile not found."
        case .invalidPhone: return "Enter a valid phone number."
        }
    }
}

enum MockPhoneState {
    static var phoneE164: String?
    static var phoneVerified = false
    static var phoneDiscoverable = false
    static var smsNotificationsEnabled = false

    static func apply(to profile: UserProfile) -> UserProfile {
        var copy = profile
        copy.phoneE164 = phoneE164
        copy.phoneVerified = phoneVerified
        copy.phoneDiscoverable = phoneDiscoverable
        copy.smsNotificationsEnabled = smsNotificationsEnabled
        return copy
    }
}

@MainActor
final class MockPhoneService: PhoneServiceProtocol {
    func requestVerification(phone: String) async throws -> PhoneVerificationResponse {
        guard let e164 = PhoneNormalizer.toE164(phone) else { throw PhoneServiceError.invalidPhone }
        MockPhoneState.phoneE164 = e164
        MockPhoneState.phoneVerified = false
        return PhoneVerificationResponse(phoneE164: e164, expiresInSeconds: 600)
    }

    func verifyCode(_ code: String) async throws -> UserProfile {
        guard code.trimmingCharacters(in: .whitespacesAndNewlines) == "123456" else {
            throw NSError(domain: "Zuvaro", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code. Use 123456 in demo mode."])
        }
        MockPhoneState.phoneVerified = true
        let userId = ZuvaroServices.shared.auth.currentUserId ?? UUID()
        let base = try await ZuvaroServices.shared.profiles.fetchProfile(userId: userId)
        return MockPhoneState.apply(to: base)
    }

    func updatePreferences(discoverable: Bool, smsEnabled: Bool) async throws -> UserProfile {
        MockPhoneState.phoneDiscoverable = discoverable
        MockPhoneState.smsNotificationsEnabled = smsEnabled
        let userId = ZuvaroServices.shared.auth.currentUserId ?? UUID()
        let base = try await ZuvaroServices.shared.profiles.fetchProfile(userId: userId)
        return MockPhoneState.apply(to: base)
    }

    func findFriends(phoneNumbers: [String]) async throws -> [ContactFriendMatch] {
        _ = phoneNumbers
        return MockData.contactFriends
    }

    func removePhone() async throws -> UserProfile {
        MockPhoneState.phoneE164 = nil
        MockPhoneState.phoneVerified = false
        MockPhoneState.phoneDiscoverable = false
        MockPhoneState.smsNotificationsEnabled = false
        let userId = ZuvaroServices.shared.auth.currentUserId ?? UUID()
        let base = try await ZuvaroServices.shared.profiles.fetchProfile(userId: userId)
        return MockPhoneState.apply(to: base)
    }
}
