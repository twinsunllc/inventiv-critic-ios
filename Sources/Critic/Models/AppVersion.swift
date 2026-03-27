import Foundation

/// Represents a specific version of an application.
public struct AppVersion: Codable, Sendable, Equatable {

    /// The unique identifier (UUID) for this version.
    public let id: String?

    /// The version code (build number).
    public let code: String

    /// The version name (display string).
    public let name: String

    public init(id: String? = nil, code: String, name: String) {
        self.id = id
        self.code = code
        self.name = name
    }
}
