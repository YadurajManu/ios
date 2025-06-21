import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var dashboardViewModel = StudentDashboardViewModel()
    @State private var selectedTab: StudentTab = .home
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main Content
                    TabView(selection: $selectedTab) {
                        StudentHomeView()
                            .environmentObject(authService)
                            .environmentObject(dashboardViewModel)
                            .tag(StudentTab.home)
                        
                        StudentAttendanceView()
                            .environmentObject(dashboardViewModel)
                            .tag(StudentTab.attendance)
                        
                        StudentAssignmentsView()
                            .environmentObject(dashboardViewModel)
                            .tag(StudentTab.assignments)
                        
                        StudentRegistrationView()
                            .environmentObject(dashboardViewModel)
                            .tag(StudentTab.registration)
                        
                        StudentNoticesView()
                            .environmentObject(dashboardViewModel)
                            .tag(StudentTab.notices)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Bottom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            dashboardViewModel.loadDashboardData()
        }
    }
}

// MARK: - Student Tab Enum
enum StudentTab: String, CaseIterable {
    case home = "home"
    case attendance = "attendance"
    case assignments = "assignments"
    case registration = "registration"
    case notices = "notices"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .attendance: return "Attendance"
        case .assignments: return "Assignments"
        case .registration: return "Registration"
        case .notices: return "Notices"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .attendance: return "chart.bar.fill"
        case .assignments: return "doc.text.fill"
        case .registration: return "rectangle.and.pencil.and.ellipsis"
        case .notices: return "bell.fill"
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: StudentTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(StudentTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == tab ? .red : .gray)
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(selectedTab == tab ? .semibold : .medium)
                            .foregroundColor(selectedTab == tab ? .red : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: -2)
        )
    }
}

#Preview {
    StudentDashboardView()
        .environmentObject(AuthenticationService())
} 