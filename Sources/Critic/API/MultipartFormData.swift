import Foundation

/// Builds multipart/form-data request bodies for file uploads.
public struct MultipartFormData: Sendable {

    /// The content type header value including the boundary.
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    private let boundary: String
    private var parts: [Data]

    /// Creates a new multipart form data builder.
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.parts = []
    }

    /// Adds a text field to the form data.
    public mutating func addField(name: String, value: String) {
        var part = Data()
        part.append("--\(boundary)\r\n")
        part.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        part.append("\r\n")
        part.append("\(value)\r\n")
        parts.append(part)
    }

    /// Adds a file to the form data.
    public mutating func addFile(name: String, filename: String, mimeType: String, data: Data) {
        var part = Data()
        part.append("--\(boundary)\r\n")
        part.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        part.append("Content-Type: \(mimeType)\r\n")
        part.append("\r\n")
        part.append(data)
        part.append("\r\n")
        parts.append(part)
    }

    /// Builds the final request body data.
    public func build() -> Data {
        var body = Data()
        for part in parts {
            body.append(part)
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
