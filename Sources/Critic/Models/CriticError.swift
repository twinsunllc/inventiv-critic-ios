import Foundation

/// Errors that can occur when interacting with the Critic SDK.
public enum CriticError: Error, Sendable {

    /// The API returned an unexpected status code.
    case unexpectedStatusCode(Int)

    /// The response could not be decoded.
    case decodingFailed

    /// A network error occurred.
    case networkError(any Error & Sendable)
}
