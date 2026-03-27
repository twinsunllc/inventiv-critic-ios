import Foundation

/// Represents a bug report submitted through Critic.
public struct BugReport: Codable, Sendable {

    /// The unique identifier for this report.
    public let id: String
}
