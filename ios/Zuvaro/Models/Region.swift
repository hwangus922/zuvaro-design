import Foundation

struct Region: Identifiable, Hashable, Codable {
    let id: UUID
    let code: String
    let name: String
    let kind: Kind
    let sortOrder: Int

    enum Kind: String, Codable {
        case usRegion = "us_region"
        case country
    }

    enum CodingKeys: String, CodingKey {
        case id, code, name, kind
        case sortOrder = "sort_order"
    }

    var isUSRegion: Bool { kind == .usRegion }
}
