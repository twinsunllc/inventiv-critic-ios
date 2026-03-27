import Foundation

/// Represents an application registered with Critic.
public struct App: Codable, Sendable, Equatable {

    /// The unique identifier (UUID) for this app.
    public let id: String

    /// The app name.
    public let name: String?

    /// The platform (e.g. "iOS", "Android").
    public let platform: String?

    public init(id: String, name: String? = nil, platform: String? = nil) {
        self.id = id
        self.name = name
        self.platform = platform
    }
}
