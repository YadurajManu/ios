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
                schoolId: "SCH001",
                departmentName: "Computer Science & Engineering",
                departmentCode: "CSE",
                departmentType: "Engineering",
                hodId: "HOD001",
                researchAreas: ["AI/ML", "Data Science", "Cybersecurity"],
                facilities: ["Computer Labs", "Research Center"],
                collaborations: ["Industry Partners", "Universities"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT002",
                schoolId: "SCH001",
                departmentName: "Information Technology",
                departmentCode: "IT",
                departmentType: "Engineering",
                hodId: "HOD002",
                researchAreas: ["Software Engineering", "Web Technologies"],
                facilities: ["IT Labs", "Innovation Center"],
                collaborations: ["Tech Companies", "Startups"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT003",
                schoolId: "SCH001",
                departmentName: "Electronics & Communication",
                departmentCode: "ECE",
                departmentType: "Engineering",
                hodId: "HOD003",
                researchAreas: ["VLSI", "Communication Systems"],
                facilities: ["Electronics Labs", "Signal Processing Lab"],
                collaborations: ["Electronics Companies", "Research Institutes"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT004",
                schoolId: "SCH001",
                departmentName: "Mechanical Engineering",
                departmentCode: "ME",
                departmentType: "Engineering",
                hodId: "HOD004",
                researchAreas: ["Robotics", "Manufacturing"],
                facilities: ["Mechanical Labs", "Workshop"],
                collaborations: ["Manufacturing Companies", "Automotive Industry"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT005",
                schoolId: "SCH001",
                departmentName: "Civil Engineering",
                departmentCode: "CE",
                departmentType: "Engineering",
                hodId: "HOD005",
                researchAreas: ["Structural Engineering", "Transportation"],
                facilities: ["Civil Labs", "Surveying Equipment"],
                collaborations: ["Construction Companies", "Infrastructure Projects"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT006",
                schoolId: "SCH001",
                departmentName: "Electrical Engineering",
                departmentCode: "EE",
                departmentType: "Engineering",
                hodId: "HOD006",
                researchAreas: ["Power Systems", "Control Systems"],
                facilities: ["Electrical Labs", "Power Systems Lab"],
                collaborations: ["Power Companies", "Energy Sector"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT007",
                schoolId: "SCH001",
                departmentName: "Biotechnology",
                departmentCode: "BT",
                departmentType: "Science",
                hodId: "HOD007",
                researchAreas: ["Genetic Engineering", "Biomedical"],
                facilities: ["Biotech Labs", "Research Center"],
                collaborations: ["Pharmaceutical Companies", "Research Institutes"],
                createdAt: Date(),
                updatedAt: Date()
            ),
            Department(
                id: "DEPT008",
                schoolId: "SCH001",
                departmentName: "Applied Sciences",
                departmentCode: "AS",
                departmentType: "Science",
                hodId: "HOD008",
                researchAreas: ["Physics", "Chemistry", "Mathematics"],
                facilities: ["Science Labs", "Research Facilities"],
                collaborations: ["Research Organizations", "Universities"],
                createdAt: Date(),
                updatedAt: Date()
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
                color: Color.blue,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT002",
                title: "Faculty Performance Review",
                description: "Monthly faculty evaluation completed for IT department",
                timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                icon: "star.circle.fill",
                color: Color.orange,
                priority: .high
            ),
            AdminActivity(
                id: "ACT003",
                title: "System Backup Completed",
                description: "Daily system backup and data sync completed successfully",
                timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                icon: "externaldrive.fill.badge.checkmark",
                color: Color.green,
                priority: .low
            ),
            AdminActivity(
                id: "ACT004",
                title: "Course Curriculum Updated",
                description: "CSE department updated curriculum for semester 6",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                icon: "book.circle.fill",
                color: Color.purple,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT005",
                title: "Security Alert Resolved",
                description: "Unauthorized access attempt detected and blocked",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                icon: "shield.checkmark.fill",
                color: Color.red,
                priority: .high
            ),
            AdminActivity(
                id: "ACT006",
                title: "Financial Report Generated",
                description: "Monthly financial summary and budget analysis completed",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                icon: "chart.bar.doc.horizontal.fill",
                color: Color.green,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT007",
                title: "Faculty Recruitment",
                description: "3 new faculty members joined the Mechanical Engineering department",
                timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                icon: "person.2.badge.plus.fill",
                color: Color.blue,
                priority: .medium
            ),
            AdminActivity(
                id: "ACT008",
                title: "Infrastructure Maintenance",
                description: "Annual maintenance of laboratory equipment scheduled",
                timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                icon: "wrench.and.screwdriver.fill",
                color: Color.orange,
                priority: .low
            )
        ]
    }
}

// MARK: - Admin Activity Models
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
        case .low: return Color.gray
        case .medium: return Color.blue
        case .high: return Color.orange
        case .critical: return Color.red
        }
    }
} 