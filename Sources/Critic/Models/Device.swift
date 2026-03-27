import Foundation

/// Represents device information sent with reports.
public struct Device: Codable, Sendable, Equatable {

    /// The unique identifier (UUID) for this device.
    public let id: String?

    /// A device-unique identifier.
    public let identifier: String?

    /// The device manufacturer.
    public let manufacturer: String?

    /// The device model identifier.
    public let model: String?

    /// The network carrier name.
    public let networkCarrier: String?

    /// The platform (e.g. "iOS").
    public let platform: String?

    /// The platform/OS version.
    public let platformVersion: String?

    /// When the device record was created.
    public let createdAt: String?

    /// When the device record was last updated.
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case manufacturer
        case model
        case networkCarrier = "network_carrier"
        case platform
        case platformVersion = "platform_version"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(
        id: String? = nil,
        identifier: String? = nil,
        manufacturer: String? = nil,
        model: String? = nil,
        networkCarrier: String? = nil,
        platform: String? = nil,
        platformVersion: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.identifier = identifier
        self.manufacturer = manufacturer
        self.model = model
        self.networkCarrier = networkCarrier
        self.platform = platform
        self.platformVersion = platformVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
