import Foundation

/// Represents the current status/state of the device.
public struct DeviceStatus: Codable, Sendable, Equatable {

    /// The unique identifier (UUID).
    public let id: String?

    /// Whether the battery is currently charging.
    public let batteryCharging: Bool?

    /// The battery level (0–100).
    public let batteryLevel: Int?

    /// The battery health description.
    public let batteryHealth: String?

    /// Free disk space in bytes.
    public let diskFree: Int64?

    /// Platform disk space in bytes.
    public let diskPlatform: Int64?

    /// Total disk space in bytes.
    public let diskTotal: Int64?

    /// Usable disk space in bytes.
    public let diskUsable: Int64?

    /// Active memory in bytes.
    public let memoryActive: Int64?

    /// Free memory in bytes.
    public let memoryFree: Int64?

    /// Inactive memory in bytes.
    public let memoryInactive: Int64?

    /// Purgable memory in bytes.
    public let memoryPurgable: Int64?

    /// Total memory in bytes.
    public let memoryTotal: Int64?

    /// Wired memory in bytes.
    public let memoryWired: Int64?

    /// Arbitrary metadata.
    public let metadata: String?

    /// Whether cellular data is connected.
    public let networkCellConnected: Bool?

    /// Cellular signal strength in bars.
    public let networkCellSignalBars: Int?

    /// Whether WiFi is connected.
    public let networkWifiConnected: Bool?

    /// WiFi signal strength in bars.
    public let networkWifiSignalBars: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case batteryCharging = "battery_charging"
        case batteryLevel = "battery_level"
        case batteryHealth = "battery_health"
        case diskFree = "disk_free"
        case diskPlatform = "disk_platform"
        case diskTotal = "disk_total"
        case diskUsable = "disk_usable"
        case memoryActive = "memory_active"
        case memoryFree = "memory_free"
        case memoryInactive = "memory_inactive"
        case memoryPurgable = "memory_purgable"
        case memoryTotal = "memory_total"
        case memoryWired = "memory_wired"
        case metadata
        case networkCellConnected = "network_cell_connected"
        case networkCellSignalBars = "network_cell_signal_bars"
        case networkWifiConnected = "network_wifi_connected"
        case networkWifiSignalBars = "network_wifi_signal_bars"
    }

    public init(
        id: String? = nil,
        batteryCharging: Bool? = nil,
        batteryLevel: Int? = nil,
        batteryHealth: String? = nil,
        diskFree: Int64? = nil,
        diskPlatform: Int64? = nil,
        diskTotal: Int64? = nil,
        diskUsable: Int64? = nil,
        memoryActive: Int64? = nil,
        memoryFree: Int64? = nil,
        memoryInactive: Int64? = nil,
        memoryPurgable: Int64? = nil,
        memoryTotal: Int64? = nil,
        memoryWired: Int64? = nil,
        metadata: String? = nil,
        networkCellConnected: Bool? = nil,
        networkCellSignalBars: Int? = nil,
        networkWifiConnected: Bool? = nil,
        networkWifiSignalBars: Int? = nil
    ) {
        self.id = id
        self.batteryCharging = batteryCharging
        self.batteryLevel = batteryLevel
        self.batteryHealth = batteryHealth
        self.diskFree = diskFree
        self.diskPlatform = diskPlatform
        self.diskTotal = diskTotal
        self.diskUsable = diskUsable
        self.memoryActive = memoryActive
        self.memoryFree = memoryFree
        self.memoryInactive = memoryInactive
        self.memoryPurgable = memoryPurgable
        self.memoryTotal = memoryTotal
        self.memoryWired = memoryWired
        self.metadata = metadata
        self.networkCellConnected = networkCellConnected
        self.networkCellSignalBars = networkCellSignalBars
        self.networkWifiConnected = networkWifiConnected
        self.networkWifiSignalBars = networkWifiSignalBars
    }
}
