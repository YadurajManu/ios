import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Submission Service
class SubmissionService: ObservableObject {
    static let shared = SubmissionService()
    
    @Published var submissions: [AssignmentSubmission] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.mygbu.edu/v1" // Replace with actual API URL
    private let session = URLSession.shared
    
    private init() {
        loadMockSubmissions()
    }
    
    // MARK: - File Upload Functions
    
    /// Upload a file for assignment submission
    func uploadFile(fileURL: URL, assignmentId: String) async throws -> SubmissionFile {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // In production, this would upload to your backend/cloud storage
        // For now, we'll simulate the upload and create a mock file record
        
        let fileName = fileURL.lastPathComponent
        let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
        let mimeType = getMimeType(for: fileURL)
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Create mock submission file (in production, this would come from backend)
        let submissionFile = SubmissionFile(
            id: UUID().uuidString,
            fileName: "uploads/\(assignmentId)/\(UUID().uuidString)_\(fileName)",
            originalFileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType,
            fileURL: fileURL.absoluteString, // In production, this would be cloud storage URL
            uploadedAt: Date(),
            checksum: generateChecksum(for: fileURL)
        )
        
        return submissionFile
    }
    
    /// Upload multiple files
    func uploadFiles(fileURLs: [URL], assignmentId: String) async throws -> [SubmissionFile] {
        var uploadedFiles: [SubmissionFile] = []
        
        for fileURL in fileURLs {
            let file = try await uploadFile(fileURL: fileURL, assignmentId: assignmentId)
            uploadedFiles.append(file)
        }
        
        return uploadedFiles
    }
    
    // MARK: - Submission Functions
    
    /// Submit assignment with text and files
    func submitAssignment(
        assignmentId: String,
        studentId: String,
        submissionText: String,
        files: [SubmissionFile]
    ) async throws -> AssignmentSubmission {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Create submission request
        let request = SubmissionRequest(
            assignmentId: assignmentId,
            submissionText: submissionText,
            fileIds: files.map { $0.id }
        )
        
        // In production, make API call to backend
        // let response = try await makeAPICall(endpoint: "/assignments/submit", method: "POST", body: request)
        
        // For now, create mock submission
        let submission = AssignmentSubmission(
            id: UUID().uuidString,
            assignmentId: assignmentId,
            studentId: studentId,
            submissionText: submissionText,
            attachedFiles: files,
            submittedAt: Date(),
            status: .submitted,
            grade: nil,
            feedback: nil,
            gradedAt: nil,
            gradedBy: nil,
            submissionNumber: getNextSubmissionNumber(for: assignmentId, studentId: studentId),
            isLateSubmission: isLateSubmission(assignmentId: assignmentId),
            plagiarismScore: nil
        )
        
        // Add to local storage
        await MainActor.run {
            submissions.append(submission)
            saveSubmissionsLocally()
        }
        
        return submission
    }
    
    /// Save draft submission
    func saveDraft(
        assignmentId: String,
        studentId: String,
        submissionText: String,
        files: [SubmissionFile]
    ) async throws -> AssignmentSubmission {
        // Similar to submitAssignment but with draft status
        let submission = AssignmentSubmission(
            id: UUID().uuidString,
            assignmentId: assignmentId,
            studentId: studentId,
            submissionText: submissionText,
            attachedFiles: files,
            submittedAt: Date(),
            status: .draft,
            grade: nil,
            feedback: nil,
            gradedAt: nil,
            gradedBy: nil,
            submissionNumber: 0, // Drafts don't count as submission attempts
            isLateSubmission: false,
            plagiarismScore: nil
        )
        
        // Remove existing draft for this assignment
        await MainActor.run {
            submissions.removeAll { $0.assignmentId == assignmentId && $0.status == .draft }
            submissions.append(submission)
            saveSubmissionsLocally()
        }
        
        return submission
    }
    
    // MARK: - Submission History
    
    /// Get submission history for an assignment
    func getSubmissionHistory(assignmentId: String, studentId: String) async throws -> [AssignmentSubmission] {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // In production, make API call
        // let response = try await makeAPICall(endpoint: "/assignments/\(assignmentId)/submissions", method: "GET")
        
        // For now, filter local submissions
        let history = await MainActor.run {
            submissions.filter { 
                $0.assignmentId == assignmentId && $0.studentId == studentId 
            }.sorted { $0.submittedAt > $1.submittedAt }
        }
        
        return history
    }
    
    /// Get all submissions for a student
    func getAllSubmissions(studentId: String) async throws -> [AssignmentSubmission] {
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // In production, make API call
        // let response = try await makeAPICall(endpoint: "/students/\(studentId)/submissions", method: "GET")
        
        return await MainActor.run {
            submissions.filter { $0.studentId == studentId }
                .sorted { $0.submittedAt > $1.submittedAt }
        }
    }
    
    /// Delete a draft submission
    func deleteDraft(submissionId: String) async throws {
        await MainActor.run {
            submissions.removeAll { $0.id == submissionId && $0.status == .draft }
            saveSubmissionsLocally()
        }
    }
    
    // MARK: - Helper Functions
    
    private func getMimeType(for url: URL) -> String {
        if let uti = UTType(filenameExtension: url.pathExtension) {
            return uti.preferredMIMEType ?? "application/octet-stream"
        }
        return "application/octet-stream"
    }
    
    private func generateChecksum(for url: URL) -> String {
        // In production, generate actual file checksum
        return UUID().uuidString
    }
    
    private func getNextSubmissionNumber(for assignmentId: String, studentId: String) -> Int {
        let existingSubmissions = submissions.filter { 
            $0.assignmentId == assignmentId && 
            $0.studentId == studentId && 
            $0.status != .draft 
        }
        return existingSubmissions.count + 1
    }
    
    private func isLateSubmission(assignmentId: String) -> Bool {
        // In production, check against assignment due date from backend
        // For now, return false
        return false
    }
    
    // MARK: - Local Storage (for offline support)
    
    private func saveSubmissionsLocally() {
        if let encoded = try? JSONEncoder().encode(submissions) {
            UserDefaults.standard.set(encoded, forKey: "saved_submissions")
        }
    }
    
    private func loadSubmissionsLocally() {
        if let data = UserDefaults.standard.data(forKey: "saved_submissions"),
           let decoded = try? JSONDecoder().decode([AssignmentSubmission].self, from: data) {
            submissions = decoded
        }
    }
    
    private func loadMockSubmissions() {
        // Load some mock submissions for testing
        let mockSubmissions = [
            AssignmentSubmission(
                id: "SUB001",
                assignmentId: "ASG006",
                studentId: "245uai130",
                submissionText: "This is my completed software testing report. I have covered all the required testing methodologies including unit testing, integration testing, and system testing.",
                attachedFiles: [
                    SubmissionFile(
                        id: "FILE001",
                        fileName: "testing_report.pdf",
                        originalFileName: "Software_Testing_Report.pdf",
                        fileSize: 2048576,
                        mimeType: "application/pdf",
                        fileURL: "https://storage.mygbu.edu/submissions/SUB001/testing_report.pdf",
                        uploadedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                        checksum: "abc123def456"
                    )
                ],
                submittedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                status: .graded,
                grade: 85.0,
                feedback: "Good work on covering all testing methodologies. Could improve on test case documentation.",
                gradedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                gradedBy: "FAC001",
                submissionNumber: 1,
                isLateSubmission: false,
                plagiarismScore: 5.2
            )
        ]
        
        submissions.append(contentsOf: mockSubmissions)
    }
    
    // MARK: - API Helper (for future backend integration)
    
    private func makeAPICall<T: Codable>(
        endpoint: String,
        method: String,
        body: Codable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication header
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - File Picker Helper
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFiles: [URL]
    let allowedTypes: [UTType]
    let allowsMultipleSelection: Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFiles = urls
        }
    }
} 