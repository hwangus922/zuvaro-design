import Foundation

enum AppConfig {
    static var supabaseURL: URL? {
        guard let raw = bundled("SUPABASE_URL"), let url = URL(string: raw) else { return nil }
        return url
    }

    static var supabaseAnonKey: String? {
        bundled("SUPABASE_ANON_KEY")
    }

    static var isBackendConfigured: Bool {
        supabaseURL != nil && supabaseAnonKey != nil && !(supabaseAnonKey?.isEmpty ?? true)
    }

    static var useMockData: Bool {
        !isBackendConfigured
    }

    private static func bundled(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }
}
