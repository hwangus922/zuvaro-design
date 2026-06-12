import Foundation

enum PhoneNormalizer {
    /// Best-effort E.164 normalization (US-biased for 10-digit numbers).
    static func toE164(_ raw: String, defaultCountryCode: String = "1") -> String? {
        var digits = raw.filter { $0.isNumber || $0 == "+" }
        if digits.hasPrefix("+") {
            digits = "+" + digits.dropFirst().filter(\.isNumber)
        } else {
            let numbers = digits.filter(\.isNumber)
            if numbers.count == 10 {
                digits = "+\(defaultCountryCode)\(numbers)"
            } else if numbers.count == 11, numbers.hasPrefix(defaultCountryCode) {
                digits = "+\(numbers)"
            } else if numbers.count >= 8 {
                digits = "+\(numbers)"
            } else {
                return nil
            }
        }
        guard digits.count >= 8, digits.count <= 16 else { return nil }
        return digits
    }

    static func formatForDisplay(_ e164: String) -> String {
        guard e164.hasPrefix("+1"), e164.count == 12 else { return e164 }
        let area = e164.dropFirst(2).prefix(3)
        let mid = e164.dropFirst(5).prefix(3)
        let last = e164.suffix(4)
        return "(\(area)) \(mid)-\(last)"
    }
}
