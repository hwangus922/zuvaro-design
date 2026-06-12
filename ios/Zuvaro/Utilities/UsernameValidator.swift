import Foundation

enum UsernameValidator {
    static func normalize(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let withoutAt = trimmed.hasPrefix("@") ? String(trimmed.dropFirst()) : trimmed
        return withoutAt
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
    }

    static func validationMessage(for input: String) -> String? {
        let username = normalize(input)
        if username.isEmpty {
            return "Enter a username."
        }
        if username.count < 3 {
            return "At least 3 characters."
        }
        if username.count > 20 {
            return "20 characters max."
        }
        guard let first = username.first, first.isLetter || first.isNumber else {
            return "Must start with a letter or number."
        }
        return nil
    }

    static func handle(for input: String) -> String {
        "@\(normalize(input))"
    }
}
