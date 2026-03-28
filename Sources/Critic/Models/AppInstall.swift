import Foundation

/// Represents an app installation registered with Critic.
public struct AppInstall: Codable, Sendable, Equatable {

    /// The unique identifier (UUID) for this app install.
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
