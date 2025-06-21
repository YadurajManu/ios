import SwiftUI

// MARK: - Filter Enums
enum AssignmentStatusFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case submitted = "submitted"
    case overdue = "overdue"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .submitted: return "Submitted"
        case .overdue: return "Overdue"
        }
    }
}

enum AssignmentPriorityFilter: String, CaseIterable {
    case all = "all"
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

enum AssignmentSortOption: String, CaseIterable {
    case dueDate = "dueDate"
    case priority = "priority"
    case subject = "subject"
    case status = "status"
    
    var displayName: String {
        switch self {
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .subject: return "Subject"
        case .status: return "Status"
        }
    }
}

// MARK: - Extensions for Sorting
extension AssignmentStatus {
    var sortOrder: Int {
        switch self {
        case .overdue: return 0
        case .pending: return 1
        case .submitted: return 2
        }
    }
}

extension AssignmentPriority {
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .black
        }
    }
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

extension AssignmentStatus {
    var color: Color {
        switch self {
        case .pending: return .orange
        case .submitted: return .red
        case .overdue: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .submitted: return "Submitted"
        case .overdue: return "Overdue"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .submitted: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Assignment Summary Card
struct AssignmentSummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Compact Summary Card
struct CompactSummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Assignment Card
struct AssignmentCard: View {
    let assignment: Assignment
    let onTap: () -> Void
    
    private var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
    }
    
    private var isOverdue: Bool {
        assignment.dueDate < Date() && assignment.status != .submitted
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Text(assignment.subject)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(assignment.status.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(assignment.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(assignment.status.color.opacity(0.1))
                            .cornerRadius(6)
                        
                        Image(systemName: assignment.status.icon)
                            .font(.caption)
                            .foregroundColor(assignment.status.color)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(assignment.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Due Date
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatDueDate())
                                .font(.subheadline)
                                .foregroundColor(isOverdue ? .red : .primary)
                                .fontWeight(isOverdue ? .semibold : .regular)
                        }
                        
                        Spacer()
                    }
                    
                    // Countdown or Status
                    if assignment.status == .pending && !isOverdue {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(countdownText())
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    } else if isOverdue {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Text("Overdue by \(abs(daysUntilDue)) day\(abs(daysUntilDue) != 1 ? "s" : "")")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDueDate() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(assignment.dueDate, inSameDayAs: Date()) {
            return "Due Today"
        } else if calendar.isDate(assignment.dueDate, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
            return "Due Tomorrow"
        } else if daysUntilDue <= 7 && daysUntilDue > 0 {
            formatter.dateFormat = "EEEE"
            return "Due \(formatter.string(from: assignment.dueDate))"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: assignment.dueDate)
        }
    }
    
    private func countdownText() -> String {
        if daysUntilDue == 0 {
            return "Due today"
        } else if daysUntilDue == 1 {
            return "Due tomorrow"
        } else if daysUntilDue > 1 {
            return "\(daysUntilDue) days left"
        } else {
            return "Overdue"
        }
    }
}

// MARK: - Upcoming Deadline Card
struct UpcomingDeadlineCard: View {
    let assignment: Assignment
    let onTap: () -> Void
    
    private var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Priority indicator
                VStack {
                    Circle()
                        .fill(assignment.priority.color)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(assignment.priority.color.opacity(0.3))
                        .frame(width: 2)
                }
                .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(assignment.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(assignment.subject)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(countdownText())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(daysUntilDue <= 1 ? .red : .orange)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func countdownText() -> String {
        if daysUntilDue == 0 {
            return "Due today"
        } else if daysUntilDue == 1 {
            return "Due tomorrow"
        } else {
            return "\(daysUntilDue) days left"
        }
    }
}

// MARK: - Empty Assignments View
struct EmptyAssignmentsView: View {
    let message: String
    
    init(message: String = "No assignments found") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(message)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your assignments will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Assignment Filters View
struct AssignmentFiltersView: View {
    @Binding var selectedStatus: AssignmentStatusFilter
    @Binding var selectedPriority: AssignmentPriorityFilter
    @Binding var selectedSubject: String
    @Binding var sortOption: AssignmentSortOption
    let availableSubjects: [String]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Status Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AssignmentStatusFilter.allCases, id: \.self) { status in
                            FilterButton(
                                title: status.displayName,
                                isSelected: selectedStatus == status,
                                color: status == .all ? .black : getStatusColor(status)
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                }
                
                // Priority Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Priority")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AssignmentPriorityFilter.allCases, id: \.self) { priority in
                            FilterButton(
                                title: priority.displayName,
                                isSelected: selectedPriority == priority,
                                color: priority == .all ? .black : getPriorityColor(priority)
                            ) {
                                selectedPriority = priority
                            }
                        }
                    }
                }
                
                // Subject Filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subject")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(availableSubjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Sort Option
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sort By")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(AssignmentSortOption.allCases, id: \.self) { option in
                            FilterButton(
                                title: option.displayName,
                                isSelected: sortOption == option,
                                color: .red
                            ) {
                                sortOption = option
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Reset") {
                    selectedStatus = .all
                    selectedPriority = .all
                    selectedSubject = "All"
                    sortOption = .dueDate
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func getStatusColor(_ status: AssignmentStatusFilter) -> Color {
        switch status {
        case .all: return .black
        case .pending: return .orange
        case .submitted: return .red
        case .overdue: return .red
        }
    }
    
    private func getPriorityColor(_ priority: AssignmentPriorityFilter) -> Color {
        switch priority {
        case .all: return .black
        case .high: return .red
        case .medium: return .orange
        case .low: return .black
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? color : color.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Assignment Calendar View
struct AssignmentCalendarView: View {
    let assignments: [Assignment]
    let onAssignmentTap: (Assignment) -> Void
    
    @State private var selectedDate = Date()
    
    var assignmentsForSelectedDate: [Assignment] {
        assignments.filter { assignment in
            Calendar.current.isDate(assignment.dueDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Calendar
            VStack(alignment: .leading, spacing: 12) {
                Text("Assignment Calendar")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            // Assignments for selected date
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Assignments for \(formatSelectedDate())")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(assignmentsForSelectedDate.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                if assignmentsForSelectedDate.isEmpty {
                    Text("No assignments due on this date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                } else {
                    ForEach(assignmentsForSelectedDate, id: \.id) { assignment in
                        AssignmentCard(assignment: assignment) {
                            onAssignmentTap(assignment)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
} 