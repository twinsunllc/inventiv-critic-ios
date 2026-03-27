import Foundation

/// Represents the current status/state of the device.
public struct DeviceStatus: Codable, Sendable {

    /// The device battery level (0.0–1.0).
    public let batteryLevel: Float?
}
