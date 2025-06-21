import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var dashboardViewModel = StudentDashboardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
                    TabView(selection: $selectedTab) {
            // Home Tab
            StudentHomeView(selectedTab: $selectedTab)
                            .environmentObject(authService)
                            .environmentObject(dashboardViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Attendance Tab
                        StudentAttendanceView()
                            .environmentObject(dashboardViewModel)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Attendance")
                }
                .tag(1)
                        
            // Assignments Tab
                        StudentAssignmentsView()
                            .environmentObject(dashboardViewModel)
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Assignments")
                }
                .tag(2)
            
            // Registration Tab
            StudentRegistrationView(viewModel: dashboardViewModel)
                .tabItem {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    Text("Registration")
                }
                .tag(3)
                        
            // Notices Tab
                        StudentNoticesView()
                            .environmentObject(dashboardViewModel)
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notices")
                    }
                .tag(4)
        }
        .accentColor(.red) // University brand color for selected tabs
        .onAppear {
            dashboardViewModel.loadDashboardData()
            
            // Customize tab bar appearance for iOS industry standards
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected tab styling
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.red
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.red,
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
            ]
            
            // Unselected tab styling
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    StudentDashboardView()
        .environmentObject(AuthenticationService())
} 