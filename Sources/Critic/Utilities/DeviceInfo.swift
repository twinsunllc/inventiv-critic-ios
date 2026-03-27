#if canImport(UIKit)
import UIKit
#endif
import Foundation

/// Collects device information using native iOS APIs.
public struct DeviceInfo: Sendable {

    /// Creates a new DeviceInfo collector.
    public init() {}

    #if canImport(UIKit)
    /// Collects current device information for a ping request.
    @MainActor
    public func collectDeviceInfoData() -> DeviceInfoData {
        let processInfo = ProcessInfo.processInfo

        return DeviceInfoData(
            identifier: identifierForVendor(),
            manufacturer: "Apple",
            model: modelIdentifier(),
            networkCarrier: carrierName(),
            platform: "iOS",
            platformVersion: processInfo.operatingSystemVersionString
        )
    }

    /// Collects current device status (battery, disk, memory).
    @MainActor
    public func collectDeviceStatus() -> DeviceStatus {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true

        let batteryLevel = device.batteryLevel >= 0 ? Int(device.batteryLevel * 100) : nil
        let batteryCharging: Bool? = {
            switch device.batteryState {
            case .charging, .full: return true
            case .unplugged: return false
            case .unknown: return nil
            @unknown default: return nil
            }
        }()

        let diskInfo = diskSpace()
        let memoryInfo = memoryStatus()

        return DeviceStatus(
            batteryCharging: batteryCharging,
            batteryLevel: batteryLevel,
            batteryHealth: nil,
            diskFree: diskInfo.free,
            diskPlatform: nil,
            diskTotal: diskInfo.total,
            diskUsable: diskInfo.free,
            memoryActive: nil,
            memoryFree: memoryInfo.free,
            memoryInactive: nil,
            memoryPurgable: nil,
            memoryTotal: memoryInfo.total,
            memoryWired: nil,
            networkCellConnected: nil,
            networkCellSignalBars: nil,
            networkWifiConnected: nil,
            networkWifiSignalBars: nil
        )
    }
    #endif

    /// Returns the vendor identifier or a generated UUID.
    private func identifierForVendor() -> String {
        #if canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #else
        return UUID().uuidString
        #endif
    }

    /// Returns the hardware model identifier (e.g. "iPhone15,2").
    private func modelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    /// Returns the carrier name, or "Unknown" if unavailable.
    private func carrierName() -> String {
        return "Unknown"
    }

    /// Returns disk space information.
    private func diskSpace() -> (free: Int64?, total: Int64?) {
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return (nil, nil)
        }
        let free = attributes[.systemFreeSize] as? Int64
        let total = attributes[.systemSize] as? Int64
        return (free, total)
    }

    /// Returns memory usage information.
    private func memoryStatus() -> (free: Int64?, total: Int64?) {
        let total = Int64(ProcessInfo.processInfo.physicalMemory)
        // Approximate free memory using available memory
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        if result == KERN_SUCCESS {
            let free = Int64(stats.free_count) * Int64(pageSize)
            return (free, total)
        }
        return (nil, total)
    }
}
