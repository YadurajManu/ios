import SwiftUI

struct StudentSettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var showLogoutConfirmation = false
    @State private var showProfileEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header Section
                    profileHeaderSection
                        .padding(.bottom, 32)
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Academic Goals Section
                        academicGoalsSection
                        
                        // Skills & Strengths Section
                        skillsStrengthsSection
                        
                        // Account & App Settings
                        settingsGroupsSection
                        
                        // Logout Section
                        logoutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Extra space for tab bar
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showProfileEdit) {
            ProfileEditView()
                .environmentObject(dashboardViewModel)
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
            Text("Are you sure you want to logout?")
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 0) {
            if let student = dashboardViewModel.currentStudent {
                HStack(spacing: 16) {
                    // Profile Image Section (Left)
                    ZStack {
                        // Profile Image with improved design
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.15), Color.red.opacity(0.08)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 85, height: 85)
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.2), lineWidth: 2)
                                )
                            
                            if let imageURL = student.user.profileImageURL {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(.red)
                                }
                                .frame(width: 85, height: 85)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(.red)
                                    .frame(width: 85, height: 85)
                            }
                        }
                        
                        // Edit button overlay
                        Button(action: { showProfileEdit = true }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                                )
                        }
                        .offset(x: 30, y: 30)
                    }
                    
                    // Student Information Section (Right)
                    VStack(alignment: .leading, spacing: 8) {
                        // Name
                        Text(student.user.fullName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Enrollment Number with icon
                        HStack(spacing: 6) {
                            Image(systemName: "studentdesk")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text(student.enrollmentNumber)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        // Course & Branch with icon
                        HStack(spacing: 6) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text("\(student.course) - \(student.branch)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Status Badge
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text(student.registrationStatus.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.green.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    // Right side action button
                    Button(action: { showProfileEdit = true }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color(.tertiarySystemGroupedBackground))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
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
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
    }
    
    // MARK: - Academic Goals Section
    private var academicGoalsSection: some View {
        VStack(spacing: 0) {
            if let student = dashboardViewModel.currentStudent,
               let goals = student.academicGoals, !goals.isEmpty {
                
                // Section Header
                SectionHeader(
                    title: "Academic Goals",
                    subtitle: "\(goals.count) active goals",
                    icon: "target"
                )
                
                // Goals Cards
                VStack(spacing: 12) {
                    ForEach(goals.prefix(3)) { goal in
                        GoalPreviewCard(goal: goal)
                    }
                    
                    // View All Button
                    NavigationLink(destination: StudentGoalsView(goals: goals)) {
                        HStack {
                            Text("View All Goals")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                
            } else {
                EmptyStateCard(
                    icon: "target",
                    title: "No Goals Set",
                    subtitle: "Set academic goals to track your progress and achievements"
                )
            }
        }
    }
    
    // MARK: - Skills & Strengths Section
    private var skillsStrengthsSection: some View {
        VStack(spacing: 0) {
            if let student = dashboardViewModel.currentStudent,
               let skills = student.skillsStrengths, !skills.isEmpty {
                
                // Section Header
                SectionHeader(
                    title: "Skills & Strengths",
                    subtitle: "\(skills.count) skills added",
                    icon: "star.fill"
                )
                
                VStack(spacing: 16) {
                    // Skill categories summary
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(getSkillCategorySummary(skills), id: \.category) { summary in
                            ModernSkillCategorySummary(
                                category: summary.category,
                                count: summary.count,
                                color: summary.color
                            )
                        }
                    }
                    
                    // Manage Skills Button
                    NavigationLink(destination: StudentSkillsView(skills: skills)) {
                        HStack {
                            Text("Manage Skills")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                
            } else {
                EmptyStateCard(
                    icon: "star.fill",
                    title: "No Skills Added",
                    subtitle: "Add your skills and strengths to showcase your abilities"
                )
            }
        }
    }
    
    // MARK: - Settings Groups Section
    private var settingsGroupsSection: some View {
        VStack(spacing: 20) {
            // Account Settings
            SettingsGroup(title: "Account") {
                VStack(spacing: 0) {
                    ModernSettingsRow(
                        icon: "person.fill",
                        iconColor: .blue,
                        title: "Edit Profile",
                        subtitle: "Update personal information",
                        action: { showProfileEdit = true }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "key.fill",
                        iconColor: .orange,
                        title: "Change Password",
                        subtitle: "Update account password",
                        action: { /* Navigate to password change */ }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "bell.fill",
                        iconColor: .purple,
                        title: "Notifications",
                        subtitle: "Manage preferences",
                        action: { /* Navigate to notifications */ }
                    )
                }
            }
            
            // App Settings
            SettingsGroup(title: "App Settings") {
                VStack(spacing: 0) {
                    ModernSettingsRow(
                        icon: "moon.fill",
                        iconColor: .indigo,
                        title: "Appearance",
                        subtitle: "Light, Dark, or System",
                        action: { /* Toggle appearance */ }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "globe",
                        iconColor: .green,
                        title: "Language",
                        subtitle: "English (US)",
                        action: { /* Language selection */ }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "icloud.fill",
                        iconColor: .cyan,
                        title: "Data Sync",
                        subtitle: "Sync across devices",
                        action: { /* Data sync settings */ }
                    )
                }
            }
            
            // Support & Info
            SettingsGroup(title: "Support & Info") {
                VStack(spacing: 0) {
                    ModernSettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .teal,
                        title: "Help & FAQ",
                        subtitle: "Get help and answers",
                        action: { /* Navigate to help */ }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "envelope.fill",
                        iconColor: .pink,
                        title: "Contact Support",
                        subtitle: "Get in touch with us",
                        action: { /* Contact support */ }
                    )
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    ModernSettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .gray,
                        title: "About MyGBU",
                        subtitle: "Version 1.0.0",
                        action: { /* Show about */ }
                    )
                }
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
                    
                    Text("Sign out of your account")
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
    
    // MARK: - Helper Functions
    private func getSkillCategorySummary(_ skills: [Skill]) -> [(category: String, count: Int, color: Color)] {
        let categories = Dictionary(grouping: skills) { $0.category }
        return categories.map { (key, value) in
            (
                category: key.displayName,
                count: value.count,
                color: key.color
            )
        }.sorted { $0.count > $1.count }
    }
}

// MARK: - Modern Supporting Views

struct SectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 12)
    }
}

struct SettingsGroup<Content: View>: View {
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
            )
        }
    }
}

struct ModernSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
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
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct GoalPreviewCard: View {
    let goal: AcademicGoal
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(goal.type.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: goal.type.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(goal.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(goal.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(goal.progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(goal.type.color)
                }
            }
            
            Spacer()
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                    .frame(width: 36, height: 36)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(goal.type.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(goal.progress * 100))")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(goal.type.color)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct ModernSkillCategorySummary: View {
    let category: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(category)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Edit View")
                    .font(.title2)
                    .padding()
                
                Text("Coming Soon...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
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

// MARK: - Extensions
// Note: Skill.SkillCategory.color is already defined in User.swift

#Preview {
    StudentSettingsView()
        .environmentObject(AuthenticationService())
        .environmentObject(StudentDashboardViewModel())
} 