import Foundation
import Supabase

enum SupabaseManager {
    static let shared: SupabaseClient? = {
        guard AppConfig.isBackendConfigured,
              let url = AppConfig.supabaseURL,
              let key = AppConfig.supabaseAnonKey else {
            return nil
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()
}
