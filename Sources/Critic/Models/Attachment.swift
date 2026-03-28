import Foundation

/// Represents a file attachment on a bug report.
public struct Attachment: Codable, Sendable, Equatable {

    /// The unique identifier (UUID) for this attachment.
    public let id: String

    /// The original file name.
    public let fileFileName: String?

    /// The file size in bytes.
    public let fileFileSize: Int?

    /// The MIME content type.
    public let fileContentType: String?

    /// When the file was last updated.
    public let fileUpdatedAt: String?

    /// The URL to download the attachment.
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fileFileName = "file_file_name"
        case fileFileSize = "file_file_size"
        case fileContentType = "file_content_type"
        case fileUpdatedAt = "file_updated_at"
        case url
    }

    public init(
        id: String,
        fileFileName: String? = nil,
        fileFileSize: Int? = nil,
        fileContentType: String? = nil,
        fileUpdatedAt: String? = nil,
        url: String? = nil
    ) {
        self.id = id
        self.fileFileName = fileFileName
        self.fileFileSize = fileFileSize
        self.fileContentType = fileContentType
        self.fileUpdatedAt = fileUpdatedAt
        self.url = url
    }
}
