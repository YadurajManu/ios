import SwiftUI

struct StudentAssignmentsView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedStatus: AssignmentStatusFilter = .all
    @State private var selectedPriority: AssignmentPriorityFilter = .all
    @State private var selectedSubject: String = "All"
    @State private var sortOption: AssignmentSortOption = .dueDate
    @State private var showingFilters = false
    @State private var showingAssignmentDetail: Assignment?
    
    var filteredAssignments: [Assignment] {
        var assignments = dashboardViewModel.upcomingAssignments
        
        // Filter by search text
        if !searchText.isEmpty {
            assignments = assignments.filter { assignment in
                assignment.title.localizedCaseInsensitiveContains(searchText) ||
                assignment.subject.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if selectedStatus != .all {
            assignments = assignments.filter { $0.status.rawValue == selectedStatus.rawValue }
        }
        
        // Filter by priority
        if selectedPriority != .all {
            assignments = assignments.filter { $0.priority.rawValue == selectedPriority.rawValue }
        }
        
        // Filter by subject
        if selectedSubject != "All" {
            assignments = assignments.filter { $0.subject == selectedSubject }
        }
        
        // Sort assignments
        switch sortOption {
        case .dueDate:
            assignments = assignments.sorted { $0.dueDate < $1.dueDate }
        case .priority:
            assignments = assignments.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .subject:
            assignments = assignments.sorted { $0.subject < $1.subject }
        case .status:
            assignments = assignments.sorted { $0.status.sortOrder < $1.status.sortOrder }
        }
        
        return assignments
    }
    
    var availableSubjects: [String] {
        let subjects = Set(dashboardViewModel.upcomingAssignments.map { $0.subject })
        return ["All"] + Array(subjects).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search and filters
                headerSection
                
                // Assignment overview dashboard
                if selectedTab == 0 {
                    assignmentOverviewSection
                }
                
                // Tab selector
                tabSelectorSection
                
                // Content based on selected tab
                if selectedTab != 0 {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            switch selectedTab {
                            case 1:
                                pendingAssignmentsSection
                            case 2:
                                submittedAssignmentsSection
                            case 3:
                                calendarViewSection
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingFilters) {
            AssignmentFiltersView(
                selectedStatus: $selectedStatus,
                selectedPriority: $selectedPriority,
                selectedSubject: $selectedSubject,
                sortOption: $sortOption,
                availableSubjects: availableSubjects
            )
        }
        .sheet(item: $showingAssignmentDetail) { assignment in
            AssignmentDetailView(assignment: assignment, viewModel: dashboardViewModel)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Assignments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(dashboardViewModel.upcomingAssignments.count) total assignments")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingFilters = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filters")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(20)
                }
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search assignments...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
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
    }
    
    // MARK: - Assignment Overview Section
    private var assignmentOverviewSection: some View {
        VStack(spacing: 16) {
            // Compact Summary Cards in one row
            HStack(spacing: 8) {
                CompactSummaryCard(
                    title: "Total",
                    count: dashboardViewModel.upcomingAssignments.count,
                    color: .black,
                    icon: "doc.text.fill"
                )
                
                CompactSummaryCard(
                    title: "Pending",
                    count: dashboardViewModel.upcomingAssignments.filter { $0.status == .pending }.count,
                    color: .orange,
                    icon: "clock.fill"
                )
                
                CompactSummaryCard(
                    title: "Submitted",
                    count: dashboardViewModel.upcomingAssignments.filter { $0.status == .submitted }.count,
                    color: .red,
                    icon: "checkmark.circle.fill"
                )
                
                CompactSummaryCard(
                    title: "Overdue",
                    count: dashboardViewModel.upcomingAssignments.filter { $0.status == .overdue }.count,
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )
            }
            
            // Upcoming Deadlines
            upcomingDeadlinesSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Upcoming Deadlines Section
    private var upcomingDeadlinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Deadlines")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            let upcomingAssignments = dashboardViewModel.upcomingAssignments
                .filter { $0.status == .pending && $0.dueDate > Date() }
                .sorted { $0.dueDate < $1.dueDate }
                .prefix(3)
            
            if upcomingAssignments.isEmpty {
                Text("No upcoming deadlines")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(upcomingAssignments), id: \.id) { assignment in
                    UpcomingDeadlineCard(assignment: assignment) {
                        showingAssignmentDetail = assignment
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Tab Selector Section
    private var tabSelectorSection: some View {
        HStack {
            Text("View:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Menu {
                ForEach(0..<4) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        HStack {
                            Text(tabTitle(for: index))
                            if selectedTab == index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(tabTitle(for: selectedTab))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "All"
        case 1: return "Pending"
        case 2: return "Submitted"
        case 3: return "Calendar"
        default: return ""
        }
    }
    
    // MARK: - Content Sections
    private var assignmentListSection: some View {
        VStack(spacing: 12) {
            if filteredAssignments.isEmpty {
                EmptyAssignmentsView()
            } else {
                ForEach(filteredAssignments, id: \.id) { assignment in
                    AssignmentCard(assignment: assignment) {
                        showingAssignmentDetail = assignment
                    }
                }
            }
        }
    }
    
    private var pendingAssignmentsSection: some View {
        VStack(spacing: 12) {
            let pendingAssignments = filteredAssignments.filter { $0.status == .pending }
            
            if pendingAssignments.isEmpty {
                EmptyAssignmentsView(message: "No pending assignments")
            } else {
                ForEach(pendingAssignments, id: \.id) { assignment in
                    AssignmentCard(assignment: assignment) {
                        showingAssignmentDetail = assignment
                    }
                }
            }
        }
    }
    
    private var submittedAssignmentsSection: some View {
        VStack(spacing: 12) {
            let submittedAssignments = filteredAssignments.filter { $0.status == .submitted }
            
            if submittedAssignments.isEmpty {
                EmptyAssignmentsView(message: "No submitted assignments")
            } else {
                ForEach(submittedAssignments, id: \.id) { assignment in
                    AssignmentCard(assignment: assignment) {
                        showingAssignmentDetail = assignment
                    }
                }
            }
        }
    }
    
    private var calendarViewSection: some View {
        AssignmentCalendarView(assignments: filteredAssignments) { assignment in
            showingAssignmentDetail = assignment
        }
    }
}

#Preview {
    StudentAssignmentsView()
        .environmentObject(StudentDashboardViewModel())
} 