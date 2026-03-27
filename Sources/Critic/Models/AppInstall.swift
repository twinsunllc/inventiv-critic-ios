import Foundation

/// Represents an app installation registered with Critic.
public struct AppInstall: Codable, Sendable {

    /// The unique identifier for this app install.
    public let id: String
}
