import SwiftUI

struct AdminSettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    @State private var showLogoutConfirmation = false
    @State private var showProfileEdit = false
    @State private var showUserManagement = false
    @State private var showSystemSettings = false
    @State private var showSecuritySettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Admin Profile Header
                    adminProfileHeader
                        .padding(.bottom, 32)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Administrative Information
                        administrativeInformationSection
                        
                        // System Management
                        systemManagementSection
                        
                        // User & Access Control
                        userAccessControlSection
                        
                        // System Configuration
                        systemConfigurationSection
                        
                        // Security & Compliance
                        securityComplianceSection
                        
                        // Account Management
                        accountManagementSection
                        
                        // Logout Section
                        logoutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Admin Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showProfileEdit) {
            AdminProfileEditView()
                .environmentObject(adminViewModel)
        }
        .sheet(isPresented: $showUserManagement) {
            UserManagementView()
                .environmentObject(adminViewModel)
        }
        .sheet(isPresented: $showSystemSettings) {
            SystemSettingsView()
                .environmentObject(adminViewModel)
        }
        .sheet(isPresented: $showSecuritySettings) {
            SecuritySettingsView()
                .environmentObject(adminViewModel)
        }
        .alert("Admin Logout Confirmation", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authService.logout()
            }
            Button("Logout & Clear Data", role: .destructive) {
                authService.clearSavedCredentials()
                authService.logout()
            }
        } message: {
            Text("Are you sure you want to logout from admin account? This will end your administrative session.")
        }
    }
    
    // MARK: - Admin Profile Header
    private var adminProfileHeader: some View {
        VStack(spacing: 0) {
            if let admin = authService.currentAdmin {
                HStack(spacing: 20) {
                    // Profile Image Section
                    ZStack {
                        // Enhanced Profile Image Design
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.red.opacity(0.2),
                                            Color.orange.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 95, height: 95)
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
                            
                            AsyncImage(url: URL(string: admin.user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.fill.badge.shield.checkmark")
                                    .font(.system(size: 38))
                                    .foregroundColor(.red)
                            }
                            .frame(width: 95, height: 95)
                            .clipShape(Circle())
                        }
                        
                        // Admin Badge
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 28, height: 28)
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                            
                            Image(systemName: "shield.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 35, y: -35)
                        
                        // Edit button overlay
                        Button(action: { showProfileEdit = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                        }
                        .offset(x: 35, y: 35)
                    }
                    
                    // Admin Information Section
                    VStack(alignment: .leading, spacing: 8) {
                        // Name with admin indicator
                        HStack(spacing: 8) {
                            Text(admin.user.fullName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        
                        // Employee ID with icon
                        HStack(spacing: 6) {
                            Image(systemName: "number.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text("Admin ID: \(admin.employeeId)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        // Role with icon
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text(admin.role.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Department with icon
                        HStack(spacing: 6) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text(admin.department)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Permissions count
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("\(admin.permissions.count) Permissions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Joining Date
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 12))
                                .foregroundColor(.purple)
                            Text("Since \(DateFormatter.yearFormatter.string(from: admin.joiningDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.systemBackground),
                                    Color.red.opacity(0.03)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.2)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Administrative Information Section
    private var administrativeInformationSection: some View {
        AdminSettingsGroup(title: "Administrative Information") {
            if let admin = authService.currentAdmin {
                // Role & Permissions
                AdminSettingsRow(
                    icon: "crown.fill",
                    iconColor: .orange,
                    title: "Role & Permissions",
                    subtitle: "\(admin.role.displayName) • \(admin.permissions.count) permissions",
                    hasChevron: true
                ) {
                    // Navigate to role management
                }
                
                AdminSettingsDivider()
                
                // Department Management
                AdminSettingsRow(
                    icon: "building.2.fill",
                    iconColor: .blue,
                    title: "Department Access",
                    subtitle: "Manage \(admin.department) operations",
                    hasChevron: true
                ) {
                    // Navigate to department management
                }
                
                AdminSettingsDivider()
                
                // Admin Privileges
                AdminSettingsRow(
                    icon: "key.fill",
                    iconColor: .green,
                    title: "Admin Privileges",
                    subtitle: "System-wide administrative access",
                    hasChevron: true
                ) {
                    // Navigate to privileges
                }
            }
        }
    }
    
    // MARK: - System Management Section
    private var systemManagementSection: some View {
        AdminSettingsGroup(title: "System Management") {
            // User Management
            AdminSettingsRow(
                icon: "person.2.fill",
                iconColor: .blue,
                title: "User Management",
                subtitle: "Manage students, faculty, and staff",
                hasChevron: true
            ) {
                showUserManagement = true
            }
            
            AdminSettingsDivider()
            
            // Academic Management
            AdminSettingsRow(
                icon: "graduationcap.fill",
                iconColor: .purple,
                title: "Academic Management",
                subtitle: "Courses, curriculum, and academics",
                hasChevron: true
            ) {
                // Navigate to academic management
            }
            
            AdminSettingsDivider()
            
            // Department Management
            AdminSettingsRow(
                icon: "building.columns.fill",
                iconColor: .orange,
                title: "Department Management",
                subtitle: "Manage all university departments",
                hasChevron: true
            ) {
                // Navigate to department management
            }
            
            AdminSettingsDivider()
            
            // System Reports
            AdminSettingsRow(
                icon: "chart.bar.doc.horizontal.fill",
                iconColor: .green,
                title: "System Reports",
                subtitle: "Analytics and performance reports",
                hasChevron: true
            ) {
                // Navigate to reports
            }
        }
    }
    
    // MARK: - User & Access Control Section
    private var userAccessControlSection: some View {
        AdminSettingsGroup(title: "User & Access Control") {
            // Access Control
            AdminSettingsRow(
                icon: "lock.shield.fill",
                iconColor: .red,
                title: "Access Control",
                subtitle: "Manage user permissions and roles",
                hasChevron: true
            ) {
                // Navigate to access control
            }
            
            AdminSettingsDivider()
            
            // Audit Logs
            AdminSettingsRow(
                icon: "doc.text.magnifyingglass",
                iconColor: .blue,
                title: "Audit Logs",
                subtitle: "System activity and security logs",
                hasChevron: true
            ) {
                // Navigate to audit logs
            }
            
            AdminSettingsDivider()
            
            // Session Management
            AdminSettingsRow(
                icon: "clock.badge.checkmark.fill",
                iconColor: .green,
                title: "Session Management",
                subtitle: "Active sessions and timeouts",
                hasChevron: true
            ) {
                // Navigate to session management
            }
        }
    }
    
    // MARK: - System Configuration Section
    private var systemConfigurationSection: some View {
        AdminSettingsGroup(title: "System Configuration") {
            // System Settings
            AdminSettingsRow(
                icon: "gearshape.2.fill",
                iconColor: .gray,
                title: "System Settings",
                subtitle: "Configure system parameters",
                hasChevron: true
            ) {
                showSystemSettings = true
            }
            
            AdminSettingsDivider()
            
            // Database Management
            AdminSettingsRow(
                icon: "internaldrive.fill",
                iconColor: .blue,
                title: "Database Management",
                subtitle: "Backup, restore, and maintenance",
                hasChevron: true
            ) {
                // Navigate to database management
            }
            
            AdminSettingsDivider()
            
            // Email Configuration
            AdminSettingsRow(
                icon: "envelope.badge.fill",
                iconColor: .orange,
                title: "Email Configuration",
                subtitle: "SMTP settings and notifications",
                hasChevron: true
            ) {
                // Navigate to email config
            }
        }
    }
    
    // MARK: - Security & Compliance Section
    private var securityComplianceSection: some View {
        AdminSettingsGroup(title: "Security & Compliance") {
            // Security Settings
            AdminSettingsRow(
                icon: "shield.checkmark.fill",
                iconColor: .red,
                title: "Security Settings",
                subtitle: "System security and encryption",
                hasChevron: true
            ) {
                showSecuritySettings = true
            }
            
            AdminSettingsDivider()
            
            // Compliance Management
            AdminSettingsRow(
                icon: "checkmark.seal.fill",
                iconColor: .green,
                title: "Compliance Management",
                subtitle: "Data protection and regulatory compliance",
                hasChevron: true
            ) {
                // Navigate to compliance
            }
            
            AdminSettingsDivider()
            
            // Backup & Recovery
            AdminSettingsRow(
                icon: "externaldrive.badge.checkmark",
                iconColor: .blue,
                title: "Backup & Recovery",
                subtitle: "Data backup and disaster recovery",
                hasChevron: true
            ) {
                // Navigate to backup settings
            }
        }
    }
    
    // MARK: - Account Management Section
    private var accountManagementSection: some View {
        AdminSettingsGroup(title: "Account Management") {
            // Change Password
            AdminSettingsRow(
                icon: "key.horizontal.fill",
                iconColor: .orange,
                title: "Change Password",
                subtitle: "Update admin account password",
                hasChevron: true
            ) {
                // Navigate to change password
            }
            
            AdminSettingsDivider()
            
            // Two-Factor Authentication
            AdminSettingsRow(
                icon: "checkmark.shield.fill",
                iconColor: .green,
                title: "Two-Factor Authentication",
                subtitle: "Enhanced admin account security",
                hasChevron: true
            ) {
                // Navigate to 2FA setup
            }
            
            AdminSettingsDivider()
            
            // Admin Activity Log
            AdminSettingsRow(
                icon: "clock.arrow.circlepath",
                iconColor: .blue,
                title: "Admin Activity Log",
                subtitle: "Your administrative activity history",
                hasChevron: true
            ) {
                // Navigate to activity log
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
                    
                    Image(systemName: "power.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Admin Logout")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    
                    Text("End administrative session")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "shield.slash.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.6))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Admin Settings Components
struct AdminSettingsGroup<Content: View>: View {
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

struct AdminSettingsRow: View {
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

struct AdminSettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 76)
    }
}

// MARK: - Placeholder Views for Admin Sheets
struct AdminProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Admin Profile Management")
                    .font(.title2)
                    .padding()
                
                Text("Administrative profile editing functionality will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Admin Profile")
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

struct UserManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("User Management System")
                    .font(.title2)
                    .padding()
                
                Text("Comprehensive user management functionality will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("User Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SystemSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("System Configuration")
                    .font(.title2)
                    .padding()
                
                Text("System-wide configuration and settings will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("System Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var adminViewModel: AdminDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Security & Compliance")
                    .font(.title2)
                    .padding()
                
                Text("Security settings and compliance management will be implemented here")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AdminSettingsView()
        .environmentObject(AuthenticationService())
        .environmentObject(AdminDashboardViewModel())
} 