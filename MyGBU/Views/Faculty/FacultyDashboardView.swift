import SwiftUI

struct FacultyDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var facultyViewModel = FacultyDashboardViewModel()
    
    var body: some View {
        TabView {
            // Home Tab
            FacultyHomeView()
                .environmentObject(authService)
                .environmentObject(facultyViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Settings Tab
            FacultySettingsView()
                .environmentObject(authService)
                .environmentObject(facultyViewModel)
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("Settings")
                }
        }
        .accentColor(.red)
        .onAppear {
            facultyViewModel.loadFacultyData(faculty: authService.currentFaculty)
        }
    }
}

// MARK: - Faculty Home View
struct FacultyHomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var facultyViewModel: FacultyDashboardViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    facultyWelcomeHeader
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Today's Schedule
                    todaysScheduleSection
                    
                    // Recent Activities
                    recentActivitiesSection
                    
                    // Academic Overview
                    academicOverviewSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .navigationTitle("Faculty Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .refreshable {
            facultyViewModel.refreshData()
        }
    }
    
    private var facultyWelcomeHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let faculty = authService.currentFaculty {
                HStack(spacing: 16) {
                    // Profile Image
                    AsyncImage(url: URL(string: faculty.user.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Dr. \(faculty.user.fullName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(faculty.department)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text(faculty.designation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Employee ID
                        HStack(spacing: 8) {
                            Image(systemName: "number.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text("ID: \(faculty.employeeId)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color.red.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                FacultyStatCard(
                    title: "Classes Today",
                    value: "\(facultyViewModel.todaysClasses.count)",
                    icon: "calendar.badge.clock",
                    color: .blue,
                    subtitle: "Scheduled"
                )
                
                FacultyStatCard(
                    title: "Total Students",
                    value: "\(facultyViewModel.totalStudents)",
                    icon: "person.3.fill",
                    color: .green,
                    subtitle: "Enrolled"
                )
            }
            
            HStack(spacing: 16) {
                FacultyStatCard(
                    title: "Pending Reviews",
                    value: "\(facultyViewModel.pendingAssignments)",
                    icon: "doc.text.magnifyingglass",
                    color: .orange,
                    subtitle: "Assignments"
                )
                
                FacultyStatCard(
                    title: "Subjects",
                    value: "\(facultyViewModel.subjects.count)",
                    icon: "book.fill",
                    color: .purple,
                    subtitle: "Teaching"
                )
            }
        }
    }
    
    private var todaysScheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(DateFormatter.dayFormatter.string(from: Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if facultyViewModel.todaysClasses.isEmpty {
                FacultyEmptyStateCard(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Classes Today",
                    subtitle: "Enjoy your free day! Use this time for research or preparation."
                )
            } else {
                ForEach(facultyViewModel.todaysClasses) { classItem in
                    DetailedClassScheduleCard(classItem: classItem)
                }
            }
        }
    }
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activities")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full activities
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            ForEach(facultyViewModel.recentActivities.prefix(4)) { activity in
                DetailedActivityCard(activity: activity)
            }
        }
    }
    
    private var academicOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Academic Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Subjects Overview
                ForEach(facultyViewModel.subjects.prefix(3)) { subject in
                    SubjectOverviewCard(subject: subject)
                }
                
                if facultyViewModel.subjects.count > 3 {
                    HStack {
                        Text("+ \(facultyViewModel.subjects.count - 3) more subjects")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("View All Subjects") {
                            // Navigate to subjects
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                FacultyQuickActionCard(
                    title: "Create Assignment",
                    subtitle: "Add new assignment",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // Navigate to create assignment
                }
                
                FacultyQuickActionCard(
                    title: "Mark Attendance",
                    subtitle: "Record class attendance",
                    icon: "checkmark.circle.fill",
                    color: .green
                ) {
                    // Navigate to attendance marking
                }
                
                FacultyQuickActionCard(
                    title: "Grade Assignments",
                    subtitle: "Review submissions",
                    icon: "star.circle.fill",
                    color: .orange
                ) {
                    // Navigate to grading
                }
                
                FacultyQuickActionCard(
                    title: "Student Reports",
                    subtitle: "View analytics",
                    icon: "chart.bar.fill",
                    color: .purple
                ) {
                    // Navigate to reports
                }
            }
        }
    }
}

// MARK: - Enhanced Supporting Components
struct FacultyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

struct DetailedClassScheduleCard: View {
    let classItem: FacultyClass
    
    var body: some View {
        HStack(spacing: 16) {
            // Time Section
            VStack(alignment: .center, spacing: 6) {
                Text(formatTime(classItem.startTime))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 1, height: 20)
                
                Text(formatTime(classItem.endTime))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .frame(width: 70)
            
            // Class Details
            VStack(alignment: .leading, spacing: 6) {
                Text(classItem.subject.subjectName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(classItem.subject.subjectCode) • \(classItem.room)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label("Year \(classItem.year)", systemImage: "graduationcap.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Label("Section \(classItem.section)", systemImage: "person.3.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Status Indicator
            VStack(spacing: 6) {
                Circle()
                    .fill(classItem.status.color)
                    .frame(width: 12, height: 12)
                
                Text(classItem.status.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(classItem.status.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailedActivityCard: View {
    let activity: FacultyActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(activity.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activity.icon)
                    .foregroundColor(activity.color)
                    .font(.system(size: 18, weight: .medium))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Timestamp and Priority
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeAgo(activity.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SubjectOverviewCard: View {
    let subject: Subject
    
    var body: some View {
        HStack(spacing: 12) {
            // Subject Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Subject Details
            VStack(alignment: .leading, spacing: 2) {
                Text(subject.subjectName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(subject.subjectCode) • \(subject.credits) Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

struct FacultyQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FacultyEmptyStateCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
}

#Preview {
    FacultyDashboardView()
        .environmentObject(AuthenticationService())
} 