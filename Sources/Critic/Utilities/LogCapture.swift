import Foundation
import OSLog

/// Captures recent console log entries using `OSLogStore` and formats them as text
/// for attachment to bug reports.
///
/// This mirrors the Android SDK's logcat capture behavior, automatically attaching
/// the last 500 log entries (or last 5 minutes, whichever is less) to each bug report.
enum LogCapture {

    /// Maximum number of log entries to include.
    static let maxEntries = 500

    /// Maximum time window to look back (in seconds).
    static let maxTimeInterval: TimeInterval = 300 // 5 minutes

    /// Reads recent log entries for the current process and returns them as a
    /// UTF-8 encoded text attachment tuple, ready to append to a bug report's
    /// attachments array.
    ///
    /// Returns `nil` if:
    /// - A debugger is attached (avoids flooding Xcode console output)
    /// - The log store cannot be opened
    /// - No entries are found
    static func captureRecentLogs() -> (filename: String, mimeType: String, data: Data)? {
        guard !isDebuggerAttached() else { return nil }

        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(date: Date().addingTimeInterval(-maxTimeInterval))
            let entries = try store.getEntries(at: position)

            // Use a circular buffer to keep only the last `maxEntries` without
            // materializing the entire sequence into an array first.
            var ring = [OSLogEntryLog]()
            ring.reserveCapacity(maxEntries)
            var count = 0
            for entry in entries {
                guard let logEntry = entry as? OSLogEntryLog else { continue }
                if count < maxEntries {
                    ring.append(logEntry)
                } else {
                    ring[count % maxEntries] = logEntry
                }
                count += 1
            }

            let formatted: [String]
            if count <= maxEntries {
                formatted = ring.map { formatEntry($0) }
            } else {
                let start = count % maxEntries
                formatted = (ring[start...] + ring[..<start]).map { formatEntry($0) }
            }

            guard !formatted.isEmpty else { return nil }

            let text = formatted.joined(separator: "\n")
            guard let data = text.data(using: .utf8) else { return nil }

            return (filename: "console-logs.txt", mimeType: "text/plain", data: data)
        } catch {
            return nil
        }
    }

    /// Formats a single log entry as a human-readable line.
    static func formatEntry(_ entry: OSLogEntryLog) -> String {
        let timestamp = Self.entryTimestamp(entry)
        let level = levelString(entry.level)
        let category = entry.category.isEmpty ? "" : "[\(entry.category)] "
        let subsystem = entry.subsystem.isEmpty ? "" : "(\(entry.subsystem)) "
        return "\(timestamp) \(level) \(subsystem)\(category)\(entry.composedMessage)"
    }

    /// Returns an ISO-8601-ish timestamp string for a log entry.
    static func entryTimestamp(_ entry: OSLogEntry) -> String {
        iso8601Formatter.string(from: entry.date)
    }

    /// Checks whether a debugger (e.g. Xcode/LLDB) is currently attached.
    static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    // MARK: - Private

    private static let iso8601Formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    private static func levelString(_ level: OSLogEntryLog.Level) -> String {
        switch level {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .notice: return "NOTICE"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        @unknown default: return "UNKNOWN"
        }
    }
}
