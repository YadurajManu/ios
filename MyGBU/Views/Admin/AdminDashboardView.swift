import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var adminViewModel = AdminDashboardViewModel()
    
    var body: some View {
        TabView {
            // Home Tab
            AdminHomeView()
                .environmentObject(authService)
                .environmentObject(adminViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Settings Tab
            AdminSettingsView()
                .environmentObject(authService)
                .environmentObject(adminViewModel)
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("Settings")
                }
        }
        .accentColor(.red)
        .onAppear {
            adminViewModel.loadAdminData(admin: authService.currentAdmin)
        }
    }
}

// MARK: - Admin Home View
struct AdminHomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    adminWelcomeHeader
                    
                    // System Overview Stats
                    systemOverviewSection
                    
                    // Recent Activities
                    recentAdminActivitiesSection
                    
                    // University Analytics
                    universityAnalyticsSection
                    
                    // Quick Admin Actions
                    quickAdminActionsSection
                    
                    // Department Overview
                    departmentOverviewSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .refreshable {
            adminViewModel.refreshData()
        }
    }
    
    private var adminWelcomeHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let admin = authService.currentAdmin {
                HStack(spacing: 16) {
                    // Profile Image
                    AsyncImage(url: URL(string: admin.user.profileImageURL ?? "")) { image in
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
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(admin.user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(admin.role.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text(admin.department)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Employee ID
                        HStack(spacing: 8) {
                            Image(systemName: "number.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text("ID: \(admin.employeeId)")
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
    
    private var systemOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                AdminStatCard(
                    title: "Total Students",
                    value: "\(adminViewModel.totalStudents)",
                    icon: "person.3.fill",
                    color: .blue,
                    subtitle: "Enrolled"
                )
                
                AdminStatCard(
                    title: "Faculty Members",
                    value: "\(adminViewModel.totalFaculty)",
                    icon: "person.badge.shield.checkmark.fill",
                    color: .green,
                    subtitle: "Active"
                )
            }
            
            HStack(spacing: 16) {
                AdminStatCard(
                    title: "Departments",
                    value: "\(adminViewModel.departments.count)",
                    icon: "building.2.fill",
                    color: .orange,
                    subtitle: "Academic"
                )
                
                AdminStatCard(
                    title: "Active Courses",
                    value: "\(adminViewModel.activeCourses)",
                    icon: "book.fill",
                    color: .purple,
                    subtitle: "Running"
                )
            }
        }
    }
    
    private var recentAdminActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent System Activities")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full activities
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            ForEach(adminViewModel.recentActivities.prefix(4)) { activity in
                AdminActivityCard(activity: activity)
            }
        }
    }
    
    private var universityAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("University Analytics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Attendance Analytics
                AnalyticsCard(
                    title: "Average Attendance",
                    value: "\(String(format: "%.1f", adminViewModel.averageAttendance))%",
                    trend: "+2.3%",
                    trendDirection: .up,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                // Academic Performance
                AnalyticsCard(
                    title: "Average CGPA",
                    value: String(format: "%.2f", adminViewModel.averageCGPA),
                    trend: "+0.12",
                    trendDirection: .up,
                    icon: "star.fill",
                    color: .blue
                )
                
                // Faculty Performance
                AnalyticsCard(
                    title: "Faculty Satisfaction",
                    value: "\(String(format: "%.1f", adminViewModel.facultySatisfaction))%",
                    trend: "+1.8%",
                    trendDirection: .up,
                    icon: "heart.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var quickAdminActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AdminQuickActionCard(
                    title: "User Management",
                    subtitle: "Manage students & faculty",
                    icon: "person.2.fill",
                    color: .blue
                ) {
                    // Navigate to user management
                }
                
                AdminQuickActionCard(
                    title: "System Reports",
                    subtitle: "Generate analytics",
                    icon: "chart.bar.doc.horizontal.fill",
                    color: .green
                ) {
                    // Navigate to reports
                }
                
                AdminQuickActionCard(
                    title: "Course Management",
                    subtitle: "Manage curriculum",
                    icon: "book.closed.fill",
                    color: .orange
                ) {
                    // Navigate to course management
                }
                
                AdminQuickActionCard(
                    title: "System Settings",
                    subtitle: "Configure system",
                    icon: "gearshape.2.fill",
                    color: .purple
                ) {
                    // Navigate to system settings
                }
            }
        }
    }
    
    private var departmentOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Department Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Details") {
                    // Navigate to department details
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                ForEach(adminViewModel.departments.prefix(4)) { department in
                    DepartmentOverviewCard(department: department)
                }
                
                if adminViewModel.departments.count > 4 {
                    HStack {
                        Text("+ \(adminViewModel.departments.count - 4) more departments")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("View All Departments") {
                            // Navigate to all departments
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
}

// MARK: - Admin Supporting Components
struct AdminStatCard: View {
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

struct AdminActivityCard: View {
    let activity: AdminActivity
    
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
                
                if activity.priority == .high {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
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

struct AnalyticsCard: View {
    let title: String
    let value: String
    let trend: String
    let trendDirection: TrendDirection
    let icon: String
    let color: Color
    
    enum TrendDirection {
        case up, down, neutral
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Section
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .medium))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Trend Indicator
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: trendDirection.icon)
                        .font(.caption2)
                        .foregroundColor(trendDirection.color)
                    
                    Text(trend)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(trendDirection.color)
                }
                
                Text("vs last month")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

struct AdminQuickActionCard: View {
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

struct DepartmentOverviewCard: View {
    let department: Department
    
    var body: some View {
        HStack(spacing: 12) {
            // Department Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "building.2")
                    .foregroundColor(Color.blue)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Department Details
            VStack(alignment: .leading, spacing: 2) {
                Text(department.departmentName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(department.departmentCode) • \(department.departmentType)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Indicator
            VStack(alignment: .trailing, spacing: 2) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("Active")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
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

#Preview {
    AdminDashboardView()
        .environmentObject(AuthenticationService())
} 