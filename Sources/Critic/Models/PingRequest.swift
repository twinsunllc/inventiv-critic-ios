import Foundation

/// Represents a ping/heartbeat request to the Critic API.
public struct PingRequest: Codable, Sendable {

    /// The organization API token.
    public let apiToken: String

    /// The app information.
    public let app: AppInfo

    /// The device information.
    public let device: DeviceInfoData

    /// The current device status.
    public let deviceStatus: DeviceStatus?

    enum CodingKeys: String, CodingKey {
        case apiToken = "api_token"
        case app
        case device
        case deviceStatus = "device_status"
    }

    public init(apiToken: String, app: AppInfo, device: DeviceInfoData, deviceStatus: DeviceStatus? = nil) {
        self.apiToken = apiToken
        self.app = app
        self.device = device
        self.deviceStatus = deviceStatus
    }
}

/// App information sent in a ping request.
public struct AppInfo: Codable, Sendable {

    /// The app name.
    public let name: String

    /// The app bundle identifier / package name.
    public let package: String

    /// The platform (e.g. "iOS").
    public let platform: String

    /// The app version.
    public let version: AppVersionInfo

    public init(name: String, package: String, platform: String = "iOS", version: AppVersionInfo) {
        self.name = name
        self.package = package
        self.platform = platform
        self.version = version
    }
}

/// Version info sent in a ping request.
public struct AppVersionInfo: Codable, Sendable {

    /// The build number.
    public let code: String

    /// The version display name.
    public let name: String

    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}

/// Device information sent in a ping request.
public struct DeviceInfoData: Codable, Sendable {

    /// A unique device identifier.
    public let identifier: String

    /// The device manufacturer.
    public let manufacturer: String

    /// The device model.
    public let model: String

    /// The network carrier.
    public let networkCarrier: String

    /// The platform (e.g. "iOS").
    public let platform: String

    /// The platform/OS version.
    public let platformVersion: String

    enum CodingKeys: String, CodingKey {
        case identifier
        case manufacturer
        case model
        case networkCarrier = "network_carrier"
        case platform
        case platformVersion = "platform_version"
    }

    public init(
        identifier: String,
        manufacturer: String,
        model: String,
        networkCarrier: String,
        platform: String = "iOS",
        platformVersion: String
    ) {
        self.identifier = identifier
        self.manufacturer = manufacturer
        self.model = model
        self.networkCarrier = networkCarrier
        self.platform = platform
        self.platformVersion = platformVersion
    }
}

/// Response wrapper for the ping endpoint.
struct PingResponse: Codable, Sendable {
    let appInstall: AppInstall

    enum CodingKeys: String, CodingKey {
        case appInstall = "app_install"
    }
}
