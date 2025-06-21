import SwiftUI
import EventKit
import UniformTypeIdentifiers

struct AssignmentDetailView: View {
    let assignment: Assignment
    @ObservedObject var viewModel: StudentDashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingSubmissionView = false
    @State private var showingActionSheet = false
    @State private var showingCalendarAlert = false
    @State private var calendarMessage = ""
    
    private let eventStore = EKEventStore()
    
    private var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
    }
    
    private var isOverdue: Bool {
        assignment.dueDate < Date() && assignment.status != .submitted
    }
    
    private var canSubmit: Bool {
        assignment.status == .pending && !isOverdue
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Assignment Details
                    assignmentDetailsSection
                    
                    // Progress Section
                    progressSection
                    
                    // Description Section
                    descriptionSection
                    
                    // Requirements Section
                    requirementsSection
                    
                    // Submission Section
                    submissionSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            )
        }
        .sheet(isPresented: $showingSubmissionView) {
            AssignmentSubmissionView(assignment: assignment, viewModel: viewModel)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Assignment Actions"),
                buttons: [
                    .default(Text("Set Reminder")) {
                        // Set reminder functionality
                    },
                    .default(Text("Share Assignment")) {
                        // Share functionality
                    },
                    .default(Text("Download PDF")) {
                        // Download functionality
                    },
                    .cancel()
                ]
            )
        }
        .alert(isPresented: $showingCalendarAlert) {
            Alert(
                title: Text("Calendar"),
                message: Text(calendarMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Subject and Priority
            HStack {
                Text(assignment.subject)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(assignment.priority.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(assignment.priority.color.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundColor(assignment.priority.color)
                    
                    Text(assignment.priority.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(assignment.priority.color)
                }
            }
            
            // Title
            Text(assignment.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Status and Due Date
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: assignment.status.icon)
                        .font(.subheadline)
                        .foregroundColor(assignment.status.color)
                    
                    Text(assignment.status.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(assignment.status.color)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatDueDate())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isOverdue ? .red : .primary)
                    
                    if assignment.status == .pending {
                        Text(countdownText())
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .orange)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Assignment Details Section
    private var assignmentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assignment Details")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                DetailRow(
                    icon: "book.fill",
                    title: "Subject",
                    value: assignment.subject
                )
                
                DetailRow(
                    icon: "calendar",
                    title: "Due Date",
                    value: formatFullDueDate()
                )
                
                DetailRow(
                    icon: "clock",
                    title: "Time Remaining",
                    value: timeRemainingText()
                )
                
                DetailRow(
                    icon: "flag.fill",
                    title: "Priority",
                    value: assignment.priority.displayName
                )
                
                DetailRow(
                    icon: "checkmark.circle",
                    title: "Status",
                    value: assignment.status.displayName
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Completion Status")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(progressPercentage())
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(assignment.status.color)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(assignment.status.color)
                                .frame(width: geometry.size.width * progressValue(), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Status Steps
                VStack(spacing: 8) {
                    ProgressStep(
                        title: "Assignment Received",
                        isCompleted: true,
                        isActive: false
                    )
                    
                    ProgressStep(
                        title: "In Progress",
                        isCompleted: assignment.status != .pending,
                        isActive: assignment.status == .pending
                    )
                    
                    ProgressStep(
                        title: "Submitted",
                        isCompleted: assignment.status == .submitted,
                        isActive: false
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(getAssignmentDescription())
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Requirements Section
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Requirements")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(getAssignmentRequirements(), id: \.self) { requirement in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 2)
                        
                        Text(requirement)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Submission Section
    private var submissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Submission")
                .font(.headline)
                .fontWeight(.bold)
            
            if assignment.status == .submitted {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.red)
                        
                        Text("Assignment Submitted")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    Text("Submitted on \(formatSubmissionDate())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if isOverdue {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text("Assignment Overdue")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    Text("Due date has passed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        
                        Text("Pending Submission")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Text("Submit before the due date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if canSubmit {
                Button(action: {
                    showingSubmissionView = true
                }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Assignment")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                addToCalendar()
            }) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Add to Calendar")
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatDueDate() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(assignment.dueDate, inSameDayAs: Date()) {
            return "Due Today"
        } else if calendar.isDate(assignment.dueDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
            return "Due Tomorrow"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: assignment.dueDate)
        }
    }
    
    private func formatFullDueDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: assignment.dueDate)
    }
    
    private func formatSubmissionDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date()) // Mock submission date
    }
    
    private func countdownText() -> String {
        if daysUntilDue == 0 {
            return "Due today"
        } else if daysUntilDue == 1 {
            return "Due tomorrow"
        } else if daysUntilDue > 1 {
            return "\(daysUntilDue) days left"
        } else {
            return "Overdue by \(abs(daysUntilDue)) day\(abs(daysUntilDue) != 1 ? "s" : "")"
        }
    }
    
    private func timeRemainingText() -> String {
        if assignment.status == .submitted {
            return "Completed"
        } else if isOverdue {
            return "Overdue"
        } else {
            return countdownText()
        }
    }
    
    private func progressPercentage() -> String {
        switch assignment.status {
        case .pending: return "33%"
        case .submitted: return "100%"
        case .overdue: return "0%"
        }
    }
    
    private func progressValue() -> Double {
        switch assignment.status {
        case .pending: return 0.33
        case .submitted: return 1.0
        case .overdue: return 0.0
        }
    }
    
    private func getAssignmentDescription() -> String {
        // Mock description based on assignment
        switch assignment.subject {
        case "Data Structures":
            return "Implement a comprehensive data structure library including linked lists, stacks, queues, trees, and graphs. The implementation should include all basic operations with proper error handling and documentation."
        case "Operating Systems":
            return "Design and implement a process scheduling algorithm simulator. Compare different scheduling algorithms like FCFS, SJF, Round Robin, and Priority Scheduling. Provide detailed analysis of performance metrics."
        case "Database Systems":
            return "Create a complete database design for a university management system. Include ER diagrams, normalization, SQL queries, and a functional web interface for data management."
        default:
            return "Complete the assigned task according to the requirements provided in class. Make sure to follow all guidelines and submit before the deadline."
        }
    }
    
    private func getAssignmentRequirements() -> [String] {
        // Mock requirements based on assignment
        switch assignment.subject {
        case "Data Structures":
            return [
                "Implement at least 5 different data structures",
                "Include comprehensive unit tests",
                "Provide detailed documentation",
                "Code should be well-commented",
                "Submit source code and report"
            ]
        case "Operating Systems":
            return [
                "Implement 4 scheduling algorithms",
                "Create performance comparison charts",
                "Write detailed analysis report",
                "Include simulation results",
                "Provide executable program"
            ]
        case "Database Systems":
            return [
                "Design complete ER diagram",
                "Normalize to 3NF",
                "Create functional database",
                "Implement web interface",
                "Include sample data and queries"
            ]
        default:
            return [
                "Follow assignment guidelines",
                "Submit on time",
                "Include all required components",
                "Maintain academic integrity"
            ]
        }
    }
    
    // MARK: - Calendar Functions
    private func addToCalendar() {
        eventStore.requestAccess(to: .event) { [self] granted, error in
            DispatchQueue.main.async {
                if granted && error == nil {
                    self.createCalendarEvent()
                } else {
                    self.calendarMessage = "Calendar access denied. Please enable calendar permissions in Settings."
                    self.showingCalendarAlert = true
                }
            }
        }
    }
    
    private func createCalendarEvent() {
        let event = EKEvent(eventStore: eventStore)
        event.title = "\(assignment.subject): \(assignment.title)"
        event.notes = "Assignment due for \(assignment.subject)\n\nDescription: \(getAssignmentDescription())"
        
        // Set the event for the due date
        let calendar = Calendar.current
        let dueDate = assignment.dueDate
        
        // Create an all-day event on the due date
        event.startDate = calendar.startOfDay(for: dueDate)
        event.endDate = calendar.date(byAdding: .hour, value: 1, to: event.startDate) ?? event.startDate
        event.isAllDay = false
        
        // Add reminder 1 day before
        let reminder = EKAlarm(relativeOffset: -86400) // 24 hours before
        event.addAlarm(reminder)
        
        // Add another reminder 1 hour before
        let hourReminder = EKAlarm(relativeOffset: -3600) // 1 hour before
        event.addAlarm(hourReminder)
        
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            calendarMessage = "Assignment successfully added to your calendar with reminders!"
        } catch {
            calendarMessage = "Failed to add assignment to calendar. Please try again."
        }
        
        showingCalendarAlert = true
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ProgressStep: View {
    let title: String
    let isCompleted: Bool
    let isActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : isActive ? "circle.fill" : "circle")
                .foregroundColor(isCompleted ? .red : isActive ? .orange : .gray)
                .font(.subheadline)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(isCompleted ? .red : isActive ? .orange : .gray)
                .fontWeight(isCompleted || isActive ? .semibold : .regular)
            
            Spacer()
        }
    }
}

// MARK: - Assignment Submission View
struct AssignmentSubmissionView: View {
    let assignment: Assignment
    @ObservedObject var viewModel: StudentDashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var submissionService = SubmissionService.shared
    @State private var submissionText = ""
    @State private var attachedFiles: [SubmissionFile] = []
    @State private var selectedFileURLs: [URL] = []
    @State private var isSubmitting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingFilePicker = false
    @State private var showingSubmissionHistory = false
    @State private var submissionHistory: [AssignmentSubmission] = []
    @State private var existingDraft: AssignmentSubmission?
    
    private let allowedFileTypes: [UTType] = [.pdf, .plainText, .rtf, .image, .zip, .data]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Draft Notice
                    if let draft = existingDraft {
                        draftNoticeSection(draft: draft)
                    }
                    
                    // Submission History Button
                    submissionHistoryButton
                    
                    // Submission Text Area
                    textSubmissionSection
                    
                    // File Attachments
                    fileAttachmentSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("History") {
                    loadSubmissionHistory()
                }
            )
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPicker(
                selectedFiles: $selectedFileURLs,
                allowedTypes: allowedFileTypes,
                allowsMultipleSelection: true
            )
        }
        .sheet(isPresented: $showingSubmissionHistory) {
            SubmissionHistoryView(
                assignment: assignment,
                submissions: submissionHistory
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Submission Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .onAppear {
            loadExistingDraft()
        }
        .onChange(of: selectedFileURLs) { urls in
            uploadSelectedFiles(urls)
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Submit Assignment")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(assignment.title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.red)
                Text("Due: \(formatDueDate())")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(assignment.subject)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func draftNoticeSection(draft: AssignmentSubmission) -> some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Draft Found")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Last saved: \(formatDate(draft.submittedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Load Draft") {
                loadDraft(draft)
            }
            .font(.caption)
            .foregroundColor(.orange)
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var submissionHistoryButton: some View {
        Button(action: {
            loadSubmissionHistory()
        }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                
                Text("View Submission History")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var textSubmissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Submission Text")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $submissionText)
                .frame(minHeight: 150)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text("\(submissionText.count) characters")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var fileAttachmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("File Attachments")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingFilePicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add Files")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            
            if attachedFiles.isEmpty {
                Text("No files attached")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(attachedFiles, id: \.id) { file in
                    FileAttachmentRow(file: file) {
                        removeFile(file)
                    }
                }
            }
            
            if submissionService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Uploading files...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Submit Button
            Button(action: {
                submitAssignment()
            }) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    
                    Text(isSubmitting ? "Submitting..." : "Submit Assignment")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSubmitting ? Color.gray : Color.red)
                .cornerRadius(12)
            }
            .disabled(isSubmitting || submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            // Save Draft Button
            Button(action: {
                saveDraft()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save as Draft")
                        .fontWeight(.medium)
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isSubmitting)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadExistingDraft() {
        Task {
            do {
                let history = try await submissionService.getSubmissionHistory(
                    assignmentId: assignment.id,
                    studentId: "245uai130" // Replace with actual student ID
                )
                existingDraft = history.first { $0.status == .draft }
            } catch {
                print("Error loading draft: \(error)")
            }
        }
    }
    
    private func loadDraft(_ draft: AssignmentSubmission) {
        submissionText = draft.submissionText
        attachedFiles = draft.attachedFiles
    }
    
    private func loadSubmissionHistory() {
        Task {
            do {
                submissionHistory = try await submissionService.getSubmissionHistory(
                    assignmentId: assignment.id,
                    studentId: "245uai130" // Replace with actual student ID
                )
                showingSubmissionHistory = true
            } catch {
                alertMessage = "Failed to load submission history: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func uploadSelectedFiles(_ urls: [URL]) {
        Task {
            do {
                let uploadedFiles = try await submissionService.uploadFiles(
                    fileURLs: urls,
                    assignmentId: assignment.id
                )
                
                await MainActor.run {
                    attachedFiles.append(contentsOf: uploadedFiles)
                    selectedFileURLs.removeAll()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to upload files: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func removeFile(_ file: SubmissionFile) {
        attachedFiles.removeAll { $0.id == file.id }
    }
    
    private func submitAssignment() {
        isSubmitting = true
        
        Task {
            do {
                let submission = try await submissionService.submitAssignment(
                    assignmentId: assignment.id,
                    studentId: "245uai130", // Replace with actual student ID
                    submissionText: submissionText,
                    files: attachedFiles
                )
                
                await MainActor.run {
                    isSubmitting = false
                    alertMessage = "Assignment submitted successfully! Submission #\(submission.submissionNumber)"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    alertMessage = "Failed to submit assignment: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveDraft() {
        Task {
            do {
                let draft = try await submissionService.saveDraft(
                    assignmentId: assignment.id,
                    studentId: "245uai130", // Replace with actual student ID
                    submissionText: submissionText,
                    files: attachedFiles
                )
                
                await MainActor.run {
                    existingDraft = draft
                    alertMessage = "Draft saved successfully!"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to save draft: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func formatDueDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: assignment.dueDate)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Submission Views

struct FileAttachmentRow: View {
    let file: SubmissionFile
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: getFileIcon())
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.originalFileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(formatFileSize(file.fileSize))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getFileIcon() -> String {
        switch file.mimeType {
        case let type where type.contains("pdf"):
            return "doc.fill"
        case let type where type.contains("image"):
            return "photo.fill"
        case let type where type.contains("text"):
            return "doc.text.fill"
        case let type where type.contains("zip"):
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct SubmissionHistoryView: View {
    let assignment: Assignment
    let submissions: [AssignmentSubmission]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(submissions, id: \.id) { submission in
                    SubmissionHistoryRow(submission: submission)
                }
            }
            .navigationTitle("Submission History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SubmissionHistoryRow: View {
    let submission: AssignmentSubmission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: submission.status.icon)
                        .foregroundColor(submission.status.color)
                    
                    Text(submission.status.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(submission.status.color)
                }
                
                Spacer()
                
                if submission.submissionNumber > 0 {
                    Text("Attempt #\(submission.submissionNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
            }
            
            Text("Submitted: \(formatDate(submission.submittedAt))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !submission.submissionText.isEmpty {
                Text(submission.submissionText)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
            
            if !submission.attachedFiles.isEmpty {
                Text("\(submission.attachedFiles.count) file(s) attached")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if let grade = submission.grade {
                HStack {
                    Text("Grade: \(String(format: "%.1f", grade))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    if let feedback = submission.feedback {
                        Text("• \(feedback)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AssignmentDetailView(
        assignment: Assignment(
            id: "ASG001",
            title: "Data Structure Implementation",
            subject: "Data Structures",
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            status: .pending,
            priority: .high
        ),
        viewModel: StudentDashboardViewModel()
    )
}
