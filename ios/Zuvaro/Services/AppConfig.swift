import Foundation

enum AppConfig {
    static var supabaseURL: URL? {
        guard let raw = stringValue(for: "SUPABASE_URL"), !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    static var supabaseAnonKey: String? {
        guard let key = stringValue(for: "SUPABASE_ANON_KEY"), !key.isEmpty else { return nil }
        return key
    }

    static var isConfigured: Bool {
        supabaseURL != nil && supabaseAnonKey != nil
    }

    static var usesMockBackend: Bool {
        !isConfigured
    }

    private static func stringValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }
}
