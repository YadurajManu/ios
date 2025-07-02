import SwiftUI

struct FacultySettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var facultyViewModel: FacultyDashboardViewModel
    @State private var showLogoutConfirmation = false
    @State private var showProfileEdit = false
    @State private var showQualificationEdit = false
    @State private var showSubjectsManagement = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header Section
                    facultyProfileHeader
                        .padding(.bottom, 32)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Academic Information Section
                        academicInformationSection
                        
                        // Teaching Management Section
                        teachingManagementSection
                        
                        // System & App Settings
                        systemSettingsSection
                        
                        // Account Management
                        accountManagementSection
                        
                        // Logout Section
                        logoutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showProfileEdit) {
            FacultyProfileEditView()
                .environmentObject(facultyViewModel)
        }
        .sheet(isPresented: $showQualificationEdit) {
            FacultyQualificationEditView()
                .environmentObject(facultyViewModel)
        }
        .sheet(isPresented: $showSubjectsManagement) {
            FacultySubjectsManagementView()
                .environmentObject(facultyViewModel)
        }
        .alert("Logout Confirmation", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authService.logout()
            }
            Button("Logout & Clear Data", role: .destructive) {
                authService.clearSavedCredentials()
                authService.logout()
            }
        } message: {
            Text("Are you sure you want to logout? You can choose to keep your login credentials saved for faster access next time.")
        }
    }
    
    // MARK: - Faculty Profile Header
    private var facultyProfileHeader: some View {
        VStack(spacing: 0) {
            if let faculty = authService.currentFaculty {
                HStack(spacing: 20) {
                    // Profile Image Section
                    ZStack {
                        // Profile Image with enhanced design
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.15), Color.red.opacity(0.08)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.2), lineWidth: 2)
                                )
                            
                            AsyncImage(url: URL(string: faculty.user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.red)
                            }
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        }
                        
                        // Edit button overlay
                        Button(action: { showProfileEdit = true }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                                )
                        }
                        .offset(x: 32, y: 32)
                    }
                    
                    // Faculty Information Section
                    VStack(alignment: .leading, spacing: 8) {
                        // Name with title
                        Text("Dr. \(faculty.user.fullName)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Employee ID with icon
                        HStack(spacing: 6) {
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text("ID: \(faculty.employeeId)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        // Department with icon
                        HStack(spacing: 6) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text(faculty.department)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Designation with icon
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text(faculty.designation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Joining Date
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("Since \(DateFormatter.yearFormatter.string(from: faculty.joiningDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Action button
                    Button(action: { showProfileEdit = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemBackground),
                                    Color(.systemGroupedBackground).opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.separator).opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Academic Information Section
    private var academicInformationSection: some View {
                        FacultySettingsGroup(title: "Academic Information") {
            if let faculty = authService.currentFaculty {
                // Qualifications
                FacultySettingsRow(
                    icon: "graduationcap.fill",
                    iconColor: .blue,
                    title: "Qualifications",
                    subtitle: "\(faculty.qualification.count) degrees/certifications",
                    hasChevron: true
                ) {
                    showQualificationEdit = true
                }
                
                SettingsDivider()
                
                // Specializations
                FacultySettingsRow(
                    icon: "star.fill",
                    iconColor: .orange,
                    title: "Specializations",
                    subtitle: faculty.specialization.joined(separator: ", "),
                    hasChevron: true
                ) {
                    // Navigate to specializations
                }
                
                SettingsDivider()
                
                // Office Location
                FacultySettingsRow(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Office Location",
                    subtitle: faculty.officeLocation ?? "Not specified",
                    hasChevron: true
                ) {
                    // Navigate to office location
                }
            }
        }
    }
    
    // MARK: - Teaching Management Section
    private var teachingManagementSection: some View {
                        FacultySettingsGroup(title: "Teaching Management") {
            // Subjects Management
            FacultySettingsRow(
                icon: "book.fill",
                iconColor: .purple,
                title: "Subjects & Courses",
                subtitle: "Manage teaching assignments",
                hasChevron: true
            ) {
                showSubjectsManagement = true
            }
            
            SettingsDivider()
            
            // Class Schedule
            FacultySettingsRow(
                icon: "calendar.circle.fill",
                iconColor: .blue,
                title: "Class Schedule",
                subtitle: "View and manage timetable",
                hasChevron: true
            ) {
                // Navigate to schedule
            }
            
            SettingsDivider()
            
            // Assignment Templates
            FacultySettingsRow(
                icon: "doc.text.fill",
                iconColor: .orange,
                title: "Assignment Templates",
                subtitle: "Create and manage templates",
                hasChevron: true
            ) {
                // Navigate to templates
            }
            
            SettingsDivider()
            
            // Grading Preferences
            FacultySettingsRow(
                icon: "star.circle.fill",
                iconColor: .yellow,
                title: "Grading Preferences",
                subtitle: "Set grading scale and criteria",
                hasChevron: true
            ) {
                // Navigate to grading preferences
            }
        }
    }
    
    // MARK: - System Settings Section
    private var systemSettingsSection: some View {
                        FacultySettingsGroup(title: "System & Preferences") {
            // Notifications
            FacultySettingsRow(
                icon: "bell.fill",
                iconColor: .red,
                title: "Notifications",
                subtitle: "Manage notification preferences",
                hasChevron: true
            ) {
                // Navigate to notifications
            }
            
            SettingsDivider()
            
            // Privacy & Security
            FacultySettingsRow(
                icon: "lock.shield.fill",
                iconColor: .blue,
                title: "Privacy & Security",
                subtitle: "Manage data and security settings",
                hasChevron: true
            ) {
                // Navigate to privacy
            }
            
            SettingsDivider()
            
            // Data & Storage
            FacultySettingsRow(
                icon: "internaldrive.fill",
                iconColor: .gray,
                title: "Data & Storage",
                subtitle: "Manage app data and storage",
                hasChevron: true
            ) {
                // Navigate to data management
            }
            
            SettingsDivider()
            
            // App Preferences
            FacultySettingsRow(
                icon: "slider.horizontal.3",
                iconColor: .green,
                title: "App Preferences",
                subtitle: "Customize app behavior",
                hasChevron: true
            ) {
                // Navigate to app preferences
            }
        }
    }
    
    // MARK: - Account Management Section
    private var accountManagementSection: some View {
                        FacultySettingsGroup(title: "Account Management") {
            // Change Password
            FacultySettingsRow(
                icon: "key.fill",
                iconColor: .orange,
                title: "Change Password",
                subtitle: "Update your login password",
                hasChevron: true
            ) {
                // Navigate to change password
            }
            
            SettingsDivider()
            
            // Two-Factor Authentication
            FacultySettingsRow(
                icon: "checkmark.shield.fill",
                iconColor: .green,
                title: "Two-Factor Authentication",
                subtitle: "Enhanced account security",
                hasChevron: true
            ) {
                // Navigate to 2FA setup
            }
            
            SettingsDivider()
            
            // Account Backup
            FacultySettingsRow(
                icon: "icloud.fill",
                iconColor: .blue,
                title: "Account Backup",
                subtitle: "Backup your data to cloud",
                hasChevron: true
            ) {
                // Navigate to backup settings
            }
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: { showLogoutConfirmation = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Logout")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    
                    Text("Sign out of your faculty account")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Components
struct FacultySettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

struct FacultySettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let hasChevron: Bool
    let action: () -> Void
    
    init(icon: String, iconColor: Color, title: String, subtitle: String, hasChevron: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.hasChevron = hasChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 76)
    }
}

// MARK: - Placeholder Views for Sheets
struct FacultyProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var facultyViewModel: FacultyDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Faculty Profile Edit")
                    .font(.title2)
                    .padding()
                
                Text("Profile editing functionality will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct FacultyQualificationEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var facultyViewModel: FacultyDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Qualifications Management")
                    .font(.title2)
                    .padding()
                
                Text("Qualification management functionality will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Qualifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct FacultySubjectsManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var facultyViewModel: FacultyDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Subjects Management")
                    .font(.title2)
                    .padding()
                
                Text("Subjects and course management functionality will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Subjects & Courses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

#Preview {
    FacultySettingsView()
        .environmentObject(AuthenticationService())
        .environmentObject(FacultyDashboardViewModel())
} 