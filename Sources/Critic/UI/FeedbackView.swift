#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI view for collecting user feedback.
@available(iOS 16.0, *)
public struct FeedbackView: View {

    @State private var description: String = ""
    @State private var stepsToReproduce: String = ""
    @State private var isPickerPresented: Bool = false
    @State private var attachedFiles: [(filename: String, mimeType: String, data: Data)] = []
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?
    @State private var didSubmit: Bool = false

    /// Called when the user submits the report. Returns the created BugReport.
    public var onSubmit: ((BugReport) -> Void)?

    /// Called when the user cancels.
    public var onCancel: (() -> Void)?

    /// Optional user identifier to attach to the report.
    public var userIdentifier: String?

    public init(
        onSubmit: ((BugReport) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        userIdentifier: String? = nil
    ) {
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        self.userIdentifier = userIdentifier
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .accessibilityIdentifier("feedback_description")
                }

                Section("Steps to Reproduce") {
                    TextEditor(text: $stepsToReproduce)
                        .frame(minHeight: 80)
                        .accessibilityIdentifier("feedback_steps")
                }

                Section("Attachments") {
                    ForEach(Array(attachedFiles.enumerated()), id: \.offset) { index, file in
                        HStack {
                            Text(file.filename)
                            Spacer()
                            Button("Remove") {
                                attachedFiles.remove(at: index)
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    Button("Add File") {
                        isPickerPresented = true
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Submit Feedback")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        Task { await submit() }
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                }
            }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        errorMessage = nil

        let input = BugReportInput(
            description: description,
            stepsToReproduce: stepsToReproduce.isEmpty ? nil : stepsToReproduce,
            userIdentifier: userIdentifier
        )

        do {
            let bugReport = try await Critic.shared.submitReport(
                input,
                attachments: attachedFiles.isEmpty ? nil : attachedFiles
            )
            didSubmit = true
            onSubmit?(bugReport)
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
                    attachedFiles.append((
                        filename: url.lastPathComponent,
                        mimeType: mimeType,
                        data: data
                    ))
                }
            }
        case .failure:
            break
        }
    }
}
#endif
