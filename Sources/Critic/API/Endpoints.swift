import Foundation

/// Defines the available Critic API endpoints.
public enum Endpoints {

    /// The API version path prefix.
    static let basePath = "api/v3"

    /// POST /api/v3/ping
    static func ping(baseURL: URL) -> URL {
        baseURL.appending(path: "\(basePath)/ping")
    }

    /// POST /api/v3/bug_reports (create)
    /// GET  /api/v3/bug_reports (list)
    static func bugReports(baseURL: URL) -> URL {
        baseURL.appending(path: "\(basePath)/bug_reports")
    }

    /// GET /api/v3/bug_reports/:id
    static func bugReport(baseURL: URL, id: String) -> URL {
        baseURL.appending(path: "\(basePath)/bug_reports/\(id)")
    }

    /// GET /api/v3/devices
    static func devices(baseURL: URL) -> URL {
        baseURL.appending(path: "\(basePath)/devices")
    }
}
