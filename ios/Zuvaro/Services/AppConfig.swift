import Foundation

enum AppConfig {
    private static let projectHost = "wcbzqmefxkyglqhipdvo.supabase.co"

    // Fallback when Info.plist injection fails. Supabase anon keys are public client keys (RLS protects data).
    private static let fallbackAnonKey =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjYnpxbWVmeGt5Z2xxaGlwZHZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3OTE4OTEsImV4cCI6MjA5NjM2Nzg5MX0.0mMi51GqELzM01rKRtGVsRbiOvgCGAuffkvJdSP7oT4"

    static var supabaseURL: URL? {
        URL(string: "https://\(projectHost)")
    }

    static var supabaseAnonKey: String? {
        if let key = stringValue(for: "SUPABASE_ANON_KEY"), !key.isEmpty {
            return key
        }
        return fallbackAnonKey
    }

    static var isConfigured: Bool {
        supabaseURL != nil && supabaseAnonKey != nil
    }

    static var usesMockBackend: Bool {
        #if DEBUG
        !isConfigured
        #else
        false
        #endif
    }

    private static func stringValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        var trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("\""), trimmed.hasSuffix("\""), trimmed.count >= 2 {
            trimmed = String(trimmed.dropFirst().dropLast())
        }
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }
}
