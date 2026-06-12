import Foundation
import Supabase

enum SupabaseManager {
    // Hardcoded project URL avoids xcconfig/plist issues where https:// becomes "https:".
    private static let projectURL = URL(string: "https://wcbzqmefxkyglqhipdvo.supabase.co")!

    static let shared: SupabaseClient? = {
        guard let key = AppConfig.supabaseAnonKey, !key.isEmpty else { return nil }
        return SupabaseClient(supabaseURL: projectURL, supabaseKey: key)
    }()
}
