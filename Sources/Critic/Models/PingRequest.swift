import Foundation

/// Represents a ping/heartbeat request to the Critic API.
public struct PingRequest: Codable, Sendable {

    /// The app install identifier.
    public let appInstallId: String
}
