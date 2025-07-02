import Foundation
import SwiftUI
import Combine

// MARK: - Admin Dashboard ViewModel
class AdminDashboardViewModel: ObservableObject {
    @Published var currentAdmin: Admin?
    @Published var departments: [Department] = []
    @Published var recentActivities: [AdminActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // System Statistics
    @Published var totalStudents: Int = 0
    @Published var totalFaculty: Int = 0
    @Published var activeCourses: Int = 0
    @Published var averageAttendance: Double = 0.0
    @Published var averageCGPA: Double = 0.0
    @Published var facultySatisfaction: Double = 0.0
    
    init() {
        generateMockData()
    }
    
    func loadAdminData(admin: Admin?) {
        guard let admin = admin else { return }
        
        isLoading = true
        currentAdmin = admin
        
        // In a real app, this would make API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshData()
            self.isLoading = false
        }
    }
    
    func refreshData() {
        // In a real app, this would refresh from API
        generateMockData()
    }
    
    // MARK: - Mock Data Generation
    private func generateMockData() {
        generateSystemStatistics()
        generateDepartments()
        generateRecentActivities()
    }
    
    private func generateSystemStatistics() {
        totalStudents = Int.random(in: 2500...3500)
        totalFaculty = Int.random(in: 180...250)
        activeCourses = Int.random(in: 45...65)
        averageAttendance = Double.random(in: 78.0...88.0)
        averageCGPA = Double.random(in: 7.2...8.4)
        facultySatisfaction = Double.random(in: 82.0...92.0)
    }
    
    private func generateDepartments() {
        departments = [
            Department(
                id: "DEPT001",
                name: "Computer Science & Engineering",
                code: "CSE",
                facultyCount: 42,
                studentCount: 680,
                isActive: true,
                icon: "desktopcomputer",
                color: .blue
            ),
            Department(
                id: "DEPT002",
                name: "Information Technology",
                code: "IT",
                facultyCount: 38,
                studentCount: 620,
                isActive: true,
                icon: "network",
                color: .green
            ),
            Department(
                id: "DEPT003",
                name: "Electronics & Communication",
                code: "ECE",
                facultyCount: 35,
                studentCount: 580,
                isActive: true,
                icon: "antenna.radiowaves.left.and.right",
                color: .orange
            ),
            Department(
                id: "DEPT004",
                name: "Mechanical Engineering",
                code: "ME",
                facultyCount: 40,
                studentCount: 640,
                isActive: true,
                icon: "gearshape.2",
                color: .purple
            ),
            Department(
                id: "DEPT005",
                name: "Civil Engineering",
                code: "CE",
                facultyCount: 32,
                studentCount: 520,
                isActive: true,
                icon: "building.2",
                color: .brown
            ),
            Department(
                id: "DEPT006",
                name: "Electrical Engineering",
                code: "EE",
                facultyCount: 36,
                studentCount: 560,
                isActive: true,
                icon: "bolt.fill",
                color: .yellow
            ),
            Department(
                id: "DEPT007",
                name: "Biotechnology",
                code: "BT",
                facultyCount: 28,
                studentCount: 420,
                isActive: true,
                icon: "leaf.fill",
                color: .mint
            ),
            Department(
                id: "DEPT008",
                name: "Applied Sciences",
                code: "AS",
                facultyCount: 25,
                studentCount: 380,
                isActive: true,
                icon: "atom",
                color: .cyan
            )
        ]
    }
    
    private func generateRecentActivities() {
        recentActivities = [
            AdminActivity(
                id: "ACT001",
                title: "New Student Registration",
                description: "25 new students registered for admission",
                timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
                icon: "person.badge.plus.fill",
                color: .blue,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT002",
                title: "Faculty Performance Review",
                description: "Monthly faculty evaluation completed for IT department",
                timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                icon: "star.circle.fill",
                color: .orange,
                priority: .high
            ),
            AdminActivity(
                id: "ACT003",
                title: "System Backup Completed",
                description: "Daily system backup and data sync completed successfully",
                timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                icon: "externaldrive.fill.badge.checkmark",
                color: .green,
                priority: .low
            ),
            AdminActivity(
                id: "ACT004",
                title: "Course Curriculum Updated",
                description: "CSE department updated curriculum for semester 6",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                icon: "book.circle.fill",
                color: .purple,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT005",
                title: "Security Alert Resolved",
                description: "Unauthorized access attempt detected and blocked",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                icon: "shield.checkmark.fill",
                color: .red,
                priority: .high
            ),
            AdminActivity(
                id: "ACT006",
                title: "Financial Report Generated",
                description: "Monthly financial summary and budget analysis completed",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                icon: "chart.bar.doc.horizontal.fill",
                color: .green,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT007",
                title: "Faculty Recruitment",
                description: "3 new faculty members joined the Mechanical Engineering department",
                timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                icon: "person.2.badge.plus.fill",
                color: .blue,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT008",
                title: "Infrastructure Maintenance",
                description: "Annual maintenance of laboratory equipment scheduled",
                timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                icon: "wrench.and.screwdriver.fill",
                color: .orange,
                priority: .low
            )
        ]
    }
}

// MARK: - Admin Models
struct Department: Identifiable {
    let id: String
    let name: String
    let code: String
    let facultyCount: Int
    let studentCount: Int
    let isActive: Bool
    let icon: String
    let color: Color
}

struct AdminActivity: Identifiable {
    let id: String
    let title: String
    let description: String
    let timestamp: Date
    let icon: String
    let color: Color
    let priority: ActivityPriority
}

enum ActivityPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
} 