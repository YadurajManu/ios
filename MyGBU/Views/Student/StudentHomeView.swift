import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var animatedText = ""
    @State private var showProfileCard = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header with Greeting
                        headerSection
                        
                        // Hero Profile E-ID Card
                        profileEIDCard
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Recent Notices
                        recentNoticesSection
                        
                        Spacer(minLength: 100) // Space for bottom tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                }
                
                // Expanded ID Card Modal
                if dashboardViewModel.showExpandedIDCard {
                    ExpandedIDCardView()
                        .environmentObject(dashboardViewModel)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .zIndex(1000)
                }
            }
        }
        .onAppear {
            startTypewriterEffect()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Typewriter Greeting Effect
                HStack {
                    Text(animatedText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    if animatedText.count < fullGreetingText.count {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 2, height: 24)
                            .opacity(0.8)
                    }
                }
                
                if let student = dashboardViewModel.currentStudent {
                    Text("Welcome back, \(student.user.firstName)!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Logout Button
            Button(action: {
                authService.logout()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
    }
    
    // MARK: - Profile E-ID Card
    private var profileEIDCard: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                dashboardViewModel.showIDCard()
            }
        }) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Profile Image
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        if let student = dashboardViewModel.currentStudent,
                           let imageURL = student.user.profileImageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.red)
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Student Info
                    VStack(alignment: .leading, spacing: 4) {
                        if let student = dashboardViewModel.currentStudent {
                            Text(student.user.fullName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Enrollment: \(student.enrollmentNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("\(student.course) - \(student.branch)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Tap to expand indicator
                    VStack(spacing: 4) {
                        Image(systemName: "viewfinder")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("Tap to view\nE-ID Card")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Quick Stats
                if let student = dashboardViewModel.currentStudent {
                    HStack(spacing: 20) {
                        StatItem(title: "Semester", value: "\(student.semester)")
                        StatItem(title: "CGPA", value: String(format: "%.1f", student.academicInfo.cgpa ?? 0.0))
                        StatItem(title: "Attendance", value: String(format: "%.1f%%", student.academicInfo.attendance))
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .red.opacity(0.1), radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                QuickActionCard(
                    title: "Attendance",
                    icon: "chart.bar.fill",
                    color: .red,
                    action: { dashboardViewModel.refreshAttendance() }
                )
                
                QuickActionCard(
                    title: "Assignments",
                    icon: "doc.text.fill",
                    color: .red,
                    action: { dashboardViewModel.refreshAssignments() }
                )
                
                QuickActionCard(
                    title: "Registration",
                    icon: "rectangle.and.pencil.and.ellipsis",
                    color: .red,
                    action: { /* Navigate to registration */ }
                )
            }
        }
    }
    
    // MARK: - Recent Notices
    private var recentNoticesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Notices")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to notices tab
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(dashboardViewModel.recentNotices.prefix(3))) { notice in
                    NoticeCard(notice: notice)
                }
            }
        }
    }
    
    // MARK: - Typewriter Effect
    private var fullGreetingText: String {
        return dashboardViewModel.greetingMessage
    }
    
    private func startTypewriterEffect() {
        animatedText = ""
        let characters = Array(fullGreetingText)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                animatedText += String(character)
            }
        }
    }
}

// MARK: - Supporting Views
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoticeCard: View {
    let notice: Notice
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notice.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(notice.content)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text(formatDate(notice.date))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var priorityColor: Color {
        switch notice.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    StudentHomeView()
        .environmentObject(AuthenticationService())
        .environmentObject(StudentDashboardViewModel())
} 