import SwiftUI

struct StudentRegistrationView: View {
    @ObservedObject var viewModel: StudentDashboardViewModel
    @State private var showingLeaveApplicationForm = false
    @State private var showingApplicationDetails: LeaveApplication?
    @State private var searchText = ""
    
    var filteredApplications: [LeaveApplication] {
        if searchText.isEmpty {
            return viewModel.leaveApplications
        } else {
            return viewModel.leaveApplications.filter { application in
                application.leaveType.displayName.localizedCaseInsensitiveContains(searchText) ||
                application.reason.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leave Applications")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Manage your leave requests")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingLeaveApplicationForm = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Apply")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .cornerRadius(25)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search applications...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
                
                // Applications List
                if filteredApplications.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredApplications) { application in
                                LeaveApplicationCard(
                                    application: application,
                                    onTap: {
                                        showingApplicationDetails = application
                                    },
                                    onCancel: {
                                        viewModel.cancelLeaveApplication(application.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLeaveApplicationForm) {
            LeaveApplicationFormView(viewModel: viewModel)
        }
        .sheet(item: $showingApplicationDetails) { application in
            LeaveApplicationDetailView(application: application)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Leave Applications")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your leave applications will appear here once you submit them.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct LeaveApplicationCard: View {
    let application: LeaveApplication
    let onTap: () -> Void
    let onCancel: () -> Void
    
    private var statusColor: Color {
        switch application.status {
        case .pending: return .orange
        case .approved: return .black
        case .rejected: return .red
        case .cancelled: return .gray
        }
    }
    
    private var leaveTypeColor: Color {
        switch application.leaveType {
        case .medical: return .red
        case .personal: return .black
        case .emergency: return .orange
        case .family: return .black
        case .academic: return .black
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(leaveTypeColor)
                        .frame(width: 8, height: 8)
                    
                    Text(application.leaveType.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(application.status.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(8)
                    
                    if application.status == .pending {
                        Button(action: onCancel) {
                            Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                                .font(.title3)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Date Range
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text("\(application.startDate, formatter: DateFormatter.displayDate) - \(application.endDate, formatter: DateFormatter.displayDate)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Calendar.current.dateComponents([.day], from: application.startDate, to: application.endDate).day! + 1) days")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
                
                // Reason Preview
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text(application.reason)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Applied Date
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    
                    Text("Applied on \(application.appliedDate, formatter: DateFormatter.displayDateTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

struct LeaveApplicationFormView: View {
    @ObservedObject var viewModel: StudentDashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedLeaveType: LeaveType = .personal
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var isFormValid: Bool {
        !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate <= endDate &&
        reason.count >= 10
    }
    
    private var daysDifference: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Apply for Leave")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Fill in the details for your leave application")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        // Leave Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Leave Type")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(LeaveType.allCases, id: \.self) { leaveType in
                                    LeaveTypeButton(
                                        leaveType: leaveType,
                                        isSelected: selectedLeaveType == leaveType,
                                        action: { selectedLeaveType = leaveType }
                                    )
                                }
                            }
                        }
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Leave Duration")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                HStack {
                                    Text("Duration: \(daysDifference) day\(daysDifference > 1 ? "s" : "")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        
                        // Reason
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Reason")
                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(reason.count)/500")
                                    .font(.caption)
                                    .foregroundColor(reason.count > 500 ? .red : .secondary)
                            }
                            
                            TextEditor(text: $reason)
                                .frame(minHeight: 120)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(reason.count > 500 ? Color.red : Color.clear, lineWidth: 1)
                                )
                            
                            if reason.count < 10 {
                                Text("Please provide at least 10 characters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Submit Button
                        Button(action: submitApplication) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSubmitting ? "Submitting..." : "Submit Application")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color.black : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isSubmitting)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Application Submitted"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func submitApplication() {
        guard isFormValid else { return }
        
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.applyForLeave(
                leaveType: selectedLeaveType,
                startDate: startDate,
                endDate: endDate,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            isSubmitting = false
            alertMessage = "Your leave application has been submitted successfully and is pending approval."
            showingAlert = true
        }
    }
}

struct LeaveTypeButton: View {
    let leaveType: LeaveType
    let isSelected: Bool
    let action: () -> Void
    
    private var leaveTypeColor: Color {
        switch leaveType {
        case .medical: return .red
        case .personal: return .black
        case .emergency: return .orange
        case .family: return .black
        case .academic: return .black
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? leaveTypeColor : Color(.systemGray5))
                    .frame(width: 12, height: 12)
                
                Text(leaveType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? leaveTypeColor : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? leaveTypeColor.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? leaveTypeColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct LeaveApplicationDetailView: View {
    let application: LeaveApplication
    @Environment(\.presentationMode) var presentationMode
    
    private var statusColor: Color {
        switch application.status {
        case .pending: return .orange
        case .approved: return .black
        case .rejected: return .red
        case .cancelled: return .gray
        }
    }
    
    private var leaveTypeColor: Color {
        switch application.leaveType {
        case .medical: return .red
        case .personal: return .black
        case .emergency: return .orange
        case .family: return .black
        case .academic: return .black
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Circle()
                                .fill(leaveTypeColor)
                                .frame(width: 12, height: 12)
                            
                            Text(application.leaveType.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(application.status.rawValue.capitalized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(statusColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor.opacity(0.15))
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                    
                    // Details
                    VStack(spacing: 20) {
                        DetailRow(
                            icon: "calendar",
                            title: "Start Date",
                            value: DateFormatter.displayDate.string(from: application.startDate)
                        )
                        
                        DetailRow(
                            icon: "calendar",
                            title: "End Date",
                            value: DateFormatter.displayDate.string(from: application.endDate)
                        )
                        
                        DetailRow(
                            icon: "clock",
                            title: "Duration",
                            value: "\(Calendar.current.dateComponents([.day], from: application.startDate, to: application.endDate).day! + 1) days"
                        )
                        
                        DetailRow(
                            icon: "calendar.badge.clock",
                            title: "Applied On",
                            value: DateFormatter.displayDateTime.string(from: application.appliedDate)
                        )
                    }
                    
                    // Reason
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reason")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(application.reason)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    StudentRegistrationView(viewModel: StudentDashboardViewModel())
} 