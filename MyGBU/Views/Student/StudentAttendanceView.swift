import SwiftUI
import Charts

struct StudentAttendanceView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var selectedTab = 0
    @State private var showingAnalytics = false
    
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
        }
        .sheet(isPresented: $showingAnalytics) {
            AttendanceAnalyticsView(viewModel: dashboardViewModel)
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
                StatCard(
                    title: "Overall",
                    value: "\(String(format: "%.1f", viewModel.attendanceOverview?.overallPercentage ?? 0))%",
                    subtitle: "Attendance Rate",
                    color: (viewModel.attendanceOverview?.overallPercentage ?? 0) >= 75 ? .red : .gray,
                    icon: "chart.bar.fill"
                )
                
                StatCard(
                    title: "Classes",
                    value: "\(viewModel.attendanceOverview?.attendedClasses ?? 0)",
                    subtitle: "Attended",
                    color: .red,
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Streak",
                    value: "12",
                    subtitle: "Days Present",
                    color: .red,
                    icon: "flame.fill"
                )
                
                StatCard(
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
struct StatCard: View {
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

#Preview {
    StudentAttendanceView()
        .environmentObject(StudentDashboardViewModel())
} 