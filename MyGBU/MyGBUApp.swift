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
            ZStack {
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
                
                // Show loading overlay during auto-login
                if authService.isLoading && authService.savedCredentials != nil {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            .scaleEffect(1.5)
                        
                        Text("Auto-signing in...")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    )
                }
            }
            .onAppear {
                // Attempt auto-login if credentials are saved and user is not authenticated
                if !authService.isAuthenticated && authService.savedCredentials != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authService.autoLogin()
                    }
                }
            }
        }
    }
}
