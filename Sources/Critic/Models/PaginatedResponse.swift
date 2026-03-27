import Foundation

/// A generic wrapper for paginated API responses.
public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {

    /// The items in the current page.
    public let items: [T]

    /// The total number of items across all pages.
    public let totalCount: Int
}
