import Contacts
import Foundation

enum ContactsService {
    static func authorizationStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    static func requestAccess() async -> Bool {
        let store = CNContactStore()
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    /// Reads phone numbers from the address book. Numbers are normalized on device and only sent to the server for matching — contacts are not uploaded or stored.
    static func fetchPhoneNumbers(limit: Int = 500) async throws -> [String] {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactPhoneNumbersKey as CNKeyDescriptor]
        var numbers: [String] = []
        var seen = Set<String>()

        try store.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys)) { contact, stop in
            for labeled in contact.phoneNumbers {
                guard let e164 = PhoneNormalizer.toE164(labeled.value.stringValue) else { continue }
                if seen.insert(e164).inserted {
                    numbers.append(e164)
                }
                if numbers.count >= limit {
                    stop.pointee = true
                    return
                }
            }
        }
        return numbers
    }
}
