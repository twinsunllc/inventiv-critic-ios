import Foundation

/// Defines the available Critic API endpoints.
public enum Endpoints {

    /// The API version path prefix.
    static let basePath = "api/v3"

    /// POST /api/v3/ping
    static func ping(baseURL: URL) -> URL {
        baseURL.appending(path: "\(basePath)/ping")
    }

    /// POST /api/v3/bug_reports
    static func bugReports(baseURL: URL) -> URL {
        baseURL.appending(path: "\(basePath)/bug_reports")
    }
}
