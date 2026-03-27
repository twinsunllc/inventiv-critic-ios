import Foundation

/// A generic wrapper for paginated API responses.
public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {

    /// The total number of items across all pages.
    public let count: Int

    /// The current page number.
    public let currentPage: Int

    /// The total number of pages.
    public let totalPages: Int

    /// The items in the current page.
    public let items: [T]

    enum CodingKeys: String, CodingKey {
        case count
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case bugReports = "bug_reports"
        case devices
    }

    public init(count: Int, currentPage: Int, totalPages: Int, items: [T]) {
        self.count = count
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.items = items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decode(Int.self, forKey: .count)
        currentPage = try container.decode(Int.self, forKey: .currentPage)
        totalPages = try container.decode(Int.self, forKey: .totalPages)

        if let bugReports = try container.decodeIfPresent([T].self, forKey: .bugReports) {
            items = bugReports
        } else if let devices = try container.decodeIfPresent([T].self, forKey: .devices) {
            items = devices
        } else {
            items = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(currentPage, forKey: .currentPage)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(items, forKey: .bugReports)
    }
}
