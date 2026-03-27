import Foundation

/// Represents device information sent with reports.
public struct Device: Codable, Sendable {

    /// The device model identifier.
    public let model: String
}
