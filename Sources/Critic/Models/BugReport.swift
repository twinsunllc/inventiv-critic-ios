import Foundation

/// Represents a bug report submitted through Critic.
public struct BugReport: Codable, Sendable, Equatable, PaginatedItemKey {

    public static let paginatedKey = "bug_reports"

    /// The unique identifier (UUID) for this report.
    public let id: String

    /// The bug report description.
    public let description: String?

    /// Arbitrary metadata as a JSON string.
    public let metadata: String?

    /// Steps to reproduce the bug.
    public let stepsToReproduce: String?

    /// An identifier for the user who submitted the report.
    public let userIdentifier: String?

    /// When the report was created.
    public let createdAt: String?

    /// When the report was last updated.
    public let updatedAt: String?

    /// The device associated with the report.
    public let device: Device?

    /// The device status at the time of the report.
    public let deviceStatus: DeviceStatus?

    /// The app version associated with the report.
    public let appVersion: AppVersion?

    /// The app associated with the report.
    public let app: App?

    /// File attachments on the report.
    public let attachments: [Attachment]?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case metadata
        case stepsToReproduce = "steps_to_reproduce"
        case userIdentifier = "user_identifier"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case device
        case deviceStatus = "device_status"
        case appVersion = "app_version"
        case app
        case attachments
    }

    public init(
        id: String,
        description: String? = nil,
        metadata: String? = nil,
        stepsToReproduce: String? = nil,
        userIdentifier: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        device: Device? = nil,
        deviceStatus: DeviceStatus? = nil,
        appVersion: AppVersion? = nil,
        app: App? = nil,
        attachments: [Attachment]? = nil
    ) {
        self.id = id
        self.description = description
        self.metadata = metadata
        self.stepsToReproduce = stepsToReproduce
        self.userIdentifier = userIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.device = device
        self.deviceStatus = deviceStatus
        self.appVersion = appVersion
        self.app = app
        self.attachments = attachments
    }
}

/// Input data for creating a new bug report.
public struct BugReportInput: Sendable {

    /// The bug description.
    public let description: String

    /// Arbitrary metadata dictionary.
    public let metadata: [String: String]?

    /// Steps to reproduce the bug.
    public let stepsToReproduce: String?

    /// An identifier for the user submitting the report.
    public let userIdentifier: String?

    public init(
        description: String,
        metadata: [String: String]? = nil,
        stepsToReproduce: String? = nil,
        userIdentifier: String? = nil
    ) {
        self.description = description
        self.metadata = metadata
        self.stepsToReproduce = stepsToReproduce
        self.userIdentifier = userIdentifier
    }
}
