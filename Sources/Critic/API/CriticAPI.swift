import Foundation

/// Handles communication with the Critic v3 REST API.
public struct CriticAPI: Sendable {

    /// The base URL for API requests.
    public let baseURL: URL

    /// Creates a new API client.
    /// - Parameter baseURL: The base URL of the Critic API server.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
