//
//  MyGBUApp.swift
//  MyGBU
//
//  Created by Yaduraj Singh on 19/06/25.
//

import SwiftUI

@main
struct MyGBUApp: App {
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                // Navigate to appropriate dashboard based on user type
                if authService.currentStudent != nil {
                    StudentDashboardView()
                        .environmentObject(authService)
                } else if authService.currentFaculty != nil {
                    // TODO: Implement FacultyDashboardView
                    Text("Faculty Dashboard - Coming Soon")
                        .font(.title)
                        .foregroundColor(.red)
                } else if authService.currentAdmin != nil {
                    // TODO: Implement AdminDashboardView
                    Text("Admin Dashboard - Coming Soon")
                        .font(.title)
                        .foregroundColor(.red)
                }
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
