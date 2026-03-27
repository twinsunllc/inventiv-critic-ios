import Foundation

/// Errors that can occur when interacting with the Critic SDK.
public enum CriticError: Error, Sendable, Equatable {

    /// The API token is invalid (HTTP 401).
    case unauthorized

    /// Access is forbidden for the given credentials (HTTP 403).
    case forbidden

    /// The requested resource was not found (HTTP 404).
    case notFound

    /// Validation failed on the server (HTTP 422).
    case validationFailed(String)

    /// Bad request (HTTP 400).
    case badRequest(String)

    /// The API returned an unexpected status code.
    case unexpectedStatusCode(Int)

    /// The response could not be decoded.
    case decodingFailed

    /// A network error occurred.
    case networkError(String)

    /// The SDK has not been initialized.
    case notInitialized

    public static func == (lhs: CriticError, rhs: CriticError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.decodingFailed, .decodingFailed),
             (.notInitialized, .notInitialized):
            return true
        case (.validationFailed(let a), .validationFailed(let b)),
             (.badRequest(let a), .badRequest(let b)),
             (.networkError(let a), .networkError(let b)):
            return a == b
        case (.unexpectedStatusCode(let a), .unexpectedStatusCode(let b)):
            return a == b
        default:
            return false
        }
    }
}
