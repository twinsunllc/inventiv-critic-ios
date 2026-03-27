import Foundation

/// Builds multipart/form-data request bodies for file uploads.
public struct MultipartFormData: Sendable {

    /// The content type header value including the boundary.
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    private let boundary: String

    /// Creates a new multipart form data builder.
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }
}
