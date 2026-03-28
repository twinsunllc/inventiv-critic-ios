import Foundation

/// A protocol that associates a Codable item type with its JSON key in paginated responses.
public protocol PaginatedItemKey {
    /// The JSON key under which items of this type appear in paginated API responses.
    static var paginatedKey: String { get }
}

/// A generic wrapper for paginated API responses.
///
/// The decoder discovers the items array by looking up `T.paginatedKey` if `T` conforms
/// to `PaginatedItemKey`, otherwise it falls back to trying all non-metadata keys in the
/// response object. This makes it extensible to new paginated endpoints without code changes.
public struct PaginatedResponse<T: Codable & Sendable>: Sendable {

    /// The total number of items across all pages.
    public let count: Int

    /// The current page number.
    public let currentPage: Int

    /// The total number of pages.
    public let totalPages: Int

    /// The items in the current page.
    public let items: [T]

    public init(count: Int, currentPage: Int, totalPages: Int, items: [T]) {
        self.count = count
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.items = items
    }

    private enum MetadataKeys: String, CodingKey {
        case count
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }

    /// Dynamic coding key for discovering item arrays by name.
    private struct DynamicKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    private static var metadataKeyNames: Set<String> {
        ["count", "current_page", "total_pages"]
    }
}

extension PaginatedResponse: Decodable {
    public init(from decoder: Decoder) throws {
        let metaContainer = try decoder.container(keyedBy: MetadataKeys.self)
        count = try metaContainer.decode(Int.self, forKey: .count)
        currentPage = try metaContainer.decode(Int.self, forKey: .currentPage)
        totalPages = try metaContainer.decode(Int.self, forKey: .totalPages)

        let dynamicContainer = try decoder.container(keyedBy: DynamicKey.self)

        // If T declares its own paginated key, use it directly.
        if let keyed = T.self as? any PaginatedItemKey.Type,
           let key = DynamicKey(stringValue: keyed.paginatedKey) {
            items = (try? dynamicContainer.decode([T].self, forKey: key)) ?? []
            return
        }

        // Otherwise, try all non-metadata keys until we find a decodable array.
        let allKeys = dynamicContainer.allKeys
        let candidateKeys = allKeys.filter { !Self.metadataKeyNames.contains($0.stringValue) }

        for key in candidateKeys {
            if let decoded = try? dynamicContainer.decode([T].self, forKey: key) {
                items = decoded
                return
            }
        }

        items = []
    }
}

extension PaginatedResponse: Encodable {
    public func encode(to encoder: Encoder) throws {
        var metaContainer = encoder.container(keyedBy: MetadataKeys.self)
        try metaContainer.encode(count, forKey: .count)
        try metaContainer.encode(currentPage, forKey: .currentPage)
        try metaContainer.encode(totalPages, forKey: .totalPages)

        // Encode items under the correct key for the item type.
        var dynamicContainer = encoder.container(keyedBy: DynamicKey.self)
        let keyName: String
        if let keyed = T.self as? any PaginatedItemKey.Type {
            keyName = keyed.paginatedKey
        } else {
            // Fallback: use a generic "items" key.
            keyName = "items"
        }
        if let key = DynamicKey(stringValue: keyName) {
            try dynamicContainer.encode(items, forKey: key)
        }
    }
}
