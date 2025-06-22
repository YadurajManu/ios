import SwiftUI
import Charts

struct StudentAttendanceView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var selectedTab = 0
    @State private var showingAnalytics = false
    @State private var showingLeaveApplicationForm = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Analytics Button
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Attendance Overview")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let overview = dashboardViewModel.attendanceOverview {
                                Text("\(String(format: "%.1f", overview.overallPercentage))% Overall")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingAnalytics = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.bar.xaxis")
                                Text("Analytics")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(20)
                        }
                    }
                    
                    // Tab Selector
                    HStack(spacing: 0) {
                        ForEach(0..<3) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                Text(tabTitle(for: index))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedTab == index ? .red : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedTab == index ? Color.red.opacity(0.1) : Color.clear
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
                
                // Content based on selected tab
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch selectedTab {
                        case 0:
                            subjectAttendanceSection
                        case 1:
                            attendanceHistorySection
                        case 2:
                            leaveApplicationsSection
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .overlay(
                // Floating Action Button for Apply Leave (only show on Leave tab)
                Group {
                    if selectedTab == 2 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    showingLeaveApplicationForm = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Apply Leave")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(Color.red)
                                    .cornerRadius(25)
                                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 30)
                            }
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showingAnalytics) {
            AttendanceAnalyticsView(viewModel: dashboardViewModel)
        }
        .sheet(isPresented: $showingLeaveApplicationForm) {
            LeaveApplicationFormView(viewModel: dashboardViewModel)
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Subjects"
        case 1: return "History"
        case 2: return "Leave"
        default: return ""
        }
    }
    
    // MARK: - Content Sections
    private var subjectAttendanceSection: some View {
        VStack(spacing: 12) {
            if let overview = dashboardViewModel.attendanceOverview {
                // Overall Progress Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Overall Progress")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Current Semester")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(String(format: "%.1f", overview.overallPercentage))%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(overview.overallPercentage >= 75 ? .red : .gray)
                            
                            Text("\(overview.attendedClasses)/\(overview.totalClasses)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Overall Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                                                         Rectangle()
                                .fill(overview.overallPercentage >= 75 ? Color.red : Color.gray)
                                .frame(width: geometry.size.width * (overview.overallPercentage / 100), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Subject Cards
                ForEach(overview.subjectWiseAttendance) { subject in
                    SubjectAttendanceCard(subject: subject)
                }
            } else {
                ProgressView("Loading attendance data...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
    }
    
    private var attendanceHistorySection: some View {
        VStack(spacing: 12) {
            if dashboardViewModel.attendanceHistory.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Recent History")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your attendance history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ForEach(dashboardViewModel.attendanceHistory) { record in
                    AttendanceHistoryCard(record: record)
                }
            }
        }
    }
    
    private var leaveApplicationsSection: some View {
        VStack(spacing: 12) {
            if dashboardViewModel.leaveApplications.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Leave Applications")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your leave applications will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(dashboardViewModel.leaveApplications) { application in
                        LeaveApplicationCard(
                            application: application,
                            onTap: {
                                // Handle tap if needed
                            },
                            onCancel: {
                                dashboardViewModel.cancelLeaveApplication(application.id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Analytics Dashboard
struct AttendanceAnalyticsView: View {
    @ObservedObject var viewModel: StudentDashboardViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAnalyticsTab = 0
    @State private var selectedTimeRange = 0
    
    private let timeRanges = ["This Week", "This Month", "This Semester", "All Time"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Attendance Analytics")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Detailed insights and trends")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Time Range Selector
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(0..<timeRanges.count, id: \.self) { index in
                                Text(timeRanges[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Analytics Content
                    VStack(spacing: 20) {
                        // Overall Statistics Cards
                        overallStatsSection
                        
                        // Attendance Trend Chart
                        attendanceTrendChart
                        
                        // Subject Performance Chart
                        subjectPerformanceChart
                        
                        // Weekly Pattern Analysis
                        weeklyPatternChart
                        
                        // Insights and Recommendations
                        insightsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // MARK: - Analytics Sections
    private var overallStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Key Metrics")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AttendanceStatCard(
                    title: "Overall",
                    value: "\(String(format: "%.1f", viewModel.attendanceOverview?.overallPercentage ?? 0))%",
                    subtitle: "Attendance Rate",
                    color: (viewModel.attendanceOverview?.overallPercentage ?? 0) >= 75 ? .red : .gray,
                    icon: "chart.bar.fill"
                )
                
                AttendanceStatCard(
                    title: "Classes",
                    value: "\(viewModel.attendanceOverview?.attendedClasses ?? 0)",
                    subtitle: "Attended",
                    color: .red,
                    icon: "checkmark.circle.fill"
                )
                
                AttendanceStatCard(
                    title: "Streak",
                    value: "12",
                    subtitle: "Days Present",
                    color: .red,
                    icon: "flame.fill"
                )
                
                AttendanceStatCard(
                    title: "Risk Level",
                    value: (viewModel.attendanceOverview?.overallPercentage ?? 0) >= 85 ? "Low" : 
                           (viewModel.attendanceOverview?.overallPercentage ?? 0) >= 75 ? "Medium" : "High",
                    subtitle: "Assessment",
                    color: (viewModel.attendanceOverview?.overallPercentage ?? 0) >= 75 ? .red : .gray,
                    icon: "shield.fill"
                )
            }
        }
    }
    
    private var attendanceTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Attendance Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Mock trend data - in real app, this would come from viewModel
                let trendData = generateTrendData()
                
                Chart {
                    ForEach(trendData, id: \.week) { data in
                        LineMark(
                            x: .value("Week", data.week),
                            y: .value("Percentage", data.percentage)
                        )
                        .foregroundStyle(Color.red)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Week", data.week),
                            y: .value("Percentage", data.percentage)
                        )
                        .foregroundStyle(Color.red.opacity(0.1))
                    }
                    
                                            // Add reference line at 75%
                        RuleMark(y: .value("Minimum", 75))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100])
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 12, height: 3)
                        Text("Your Attendance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 12, height: 3)
                        Text("Minimum Required (75%)")
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
    }
    
    private var subjectPerformanceChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subject Performance")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                if let subjects = viewModel.attendanceOverview?.subjectWiseAttendance {
                    Chart {
                        ForEach(subjects) { subject in
                            BarMark(
                                x: .value("Subject", subject.subjectCode),
                                y: .value("Percentage", subject.percentage)
                            )
                            .foregroundStyle(subject.percentage >= 75 ? Color.red : Color.gray)
                            .cornerRadius(4)
                        }
                        
                        // Add reference line at 75%
                        RuleMark(y: .value("Minimum", 75))
                            .foregroundStyle(Color.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                    .frame(height: 200)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let code = value.as(String.self) {
                                    Text(code)
                                        .font(.caption2)
                                        .rotationEffect(.degrees(-45))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [0, 25, 50, 75, 100])
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var weeklyPatternChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Pattern")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                let weeklyData = generateWeeklyData()
                
                Chart {
                    ForEach(weeklyData, id: \.day) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Attendance", data.attendanceRate)
                        )
                        .foregroundStyle(Color.red)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 0...100)
                
                Text("Your attendance is typically lower on Mondays and Fridays")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Insights & Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                InsightCard(
                    type: .positive,
                    title: "Great Progress!",
                    description: "Your attendance has improved by 5% this month. Keep it up!",
                    icon: "arrow.up.circle.fill"
                )
                
                InsightCard(
                    type: .warning,
                    title: "Watch Out",
                    description: "Computer Networks attendance is at 68.2%. You need to attend the next 3 classes.",
                    icon: "exclamationmark.triangle.fill"
                )
                
                InsightCard(
                    type: .info,
                    title: "Pattern Detected",
                    description: "You tend to miss Friday classes. Consider setting extra reminders.",
                    icon: "lightbulb.fill"
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func generateTrendData() -> [TrendData] {
        return [
            TrendData(week: "W1", percentage: 85),
            TrendData(week: "W2", percentage: 82),
            TrendData(week: "W3", percentage: 78),
            TrendData(week: "W4", percentage: 80),
            TrendData(week: "W5", percentage: 83),
            TrendData(week: "W6", percentage: 85),
            TrendData(week: "W7", percentage: 87),
            TrendData(week: "W8", percentage: 84)
        ]
    }
    
    private func generateWeeklyData() -> [WeeklyData] {
        return [
            WeeklyData(day: "Mon", attendanceRate: 72),
            WeeklyData(day: "Tue", attendanceRate: 88),
            WeeklyData(day: "Wed", attendanceRate: 85),
            WeeklyData(day: "Thu", attendanceRate: 90),
            WeeklyData(day: "Fri", attendanceRate: 75),
            WeeklyData(day: "Sat", attendanceRate: 82)
        ]
    }
}

// MARK: - Supporting Views and Models

struct AttendanceStatCard: View {
    let title: String
    let value: String
    let subtitle: String
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
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption2)
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

struct InsightCard: View {
    enum InsightType {
        case positive, warning, info
        
        var color: Color {
            switch self {
            case .positive: return .red
            case .warning: return .red
            case .info: return .red
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .positive: return .red.opacity(0.1)
            case .warning: return .red.opacity(0.1)
            case .info: return .red.opacity(0.05)
            }
        }
    }
    
    let type: InsightType
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(type.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(type.color)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(type.backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Data Models
struct TrendData {
    let week: String
    let percentage: Double
}

struct WeeklyData {
    let day: String
    let attendanceRate: Double
}

// MARK: - Subject Attendance Card
struct SubjectAttendanceCard: View {
    let subject: SubjectAttendance
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subject.subjectName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text("\(subject.subjectCode) • \(subject.facultyName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                                         HStack(spacing: 4) {
                        Text(subject.classType.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.1))
                            .foregroundColor(.black)
                            .cornerRadius(4)
                        
                        Text(subject.status.displayText)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(subject.status.color.opacity(0.1))
                            .foregroundColor(subject.status.color)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.1f", subject.percentage))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(subject.status.color)
                    
                    Text("\(subject.attended)/\(subject.total)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Image(systemName: subject.status.icon)
                        .font(.caption)
                        .foregroundColor(subject.status.color)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(subject.status.color)
                        .frame(width: geometry.size.width * (subject.percentage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: subject.status.color.opacity(0.1), radius: 6, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(subject.status.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Attendance History Card
struct AttendanceHistoryCard: View {
    let record: AttendanceRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: record.status.icon)
                .font(.title3)
                .foregroundColor(record.status.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(record.subjectName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(record.status.displayText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(record.status.color)
                }
                
                HStack {
                    Text("\(formatDateShort(record.date)) • \(record.period)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(record.classType.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.black.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(3)
                }
                
                if let remarks = record.remarks {
                    Text(remarks)
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .italic()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(record.status.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(record.status.color.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
}

// MARK: - Leave Application Components
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
    StudentAttendanceView()
        .environmentObject(StudentDashboardViewModel())
} 