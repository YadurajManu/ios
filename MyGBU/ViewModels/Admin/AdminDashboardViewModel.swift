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
                id: 1,
                school: 1,
                departmentName: "Computer Science & Engineering",
                departmentCode: "CSE",
                departmentType: "Engineering",
                hod: 1,
                researchAreas: ["AI/ML": "Advanced AI Research", "Data Science": "Big Data Analytics", "Cybersecurity": "Network Security"],
                facilities: ["Computer Labs": "High-end computing facilities", "Research Center": "Advanced research equipment"],
                collaborations: ["Industry Partners": "Microsoft, Google", "Universities": "IITs, NITs"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 2,
                school: 1,
                departmentName: "Information Technology",
                departmentCode: "IT",
                departmentType: "Engineering",
                hod: 2,
                researchAreas: ["Software Engineering": "Agile Development", "Web Technologies": "Modern Web Apps"],
                facilities: ["IT Labs": "Software development labs", "Innovation Center": "Startup incubation"],
                collaborations: ["Tech Companies": "TCS, Infosys", "Startups": "Local tech startups"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 3,
                school: 1,
                departmentName: "Electronics & Communication",
                departmentCode: "ECE",
                departmentType: "Engineering",
                hod: 3,
                researchAreas: ["VLSI": "Chip Design", "Communication Systems": "5G Networks"],
                facilities: ["Electronics Labs": "Circuit design labs", "Signal Processing Lab": "DSP equipment"],
                collaborations: ["Electronics Companies": "Intel, Qualcomm", "Research Institutes": "DRDO, ISRO"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 4,
                school: 1,
                departmentName: "Mechanical Engineering",
                departmentCode: "ME",
                departmentType: "Engineering",
                hod: 4,
                researchAreas: ["Robotics": "Industrial Automation", "Manufacturing": "Smart Manufacturing"],
                facilities: ["Mechanical Labs": "CAD/CAM labs", "Workshop": "Machine tools"],
                collaborations: ["Manufacturing Companies": "Maruti, Tata", "Automotive Industry": "Auto manufacturers"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 5,
                school: 1,
                departmentName: "Civil Engineering",
                departmentCode: "CE",
                departmentType: "Engineering",
                hod: 5,
                researchAreas: ["Structural Engineering": "Building Design", "Transportation": "Highway Engineering"],
                facilities: ["Civil Labs": "Material testing labs", "Surveying Equipment": "Modern surveying tools"],
                collaborations: ["Construction Companies": "L&T, HCC", "Infrastructure Projects": "Government projects"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 6,
                school: 1,
                departmentName: "Electrical Engineering",
                departmentCode: "EE",
                departmentType: "Engineering",
                hod: 6,
                researchAreas: ["Power Systems": "Smart Grid", "Control Systems": "Automation"],
                facilities: ["Electrical Labs": "Power electronics labs", "Power Systems Lab": "Grid simulation"],
                collaborations: ["Power Companies": "NTPC, Power Grid", "Energy Sector": "Renewable energy"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 7,
                school: 1,
                departmentName: "Biotechnology",
                departmentCode: "BT",
                departmentType: "Science",
                hod: 7,
                researchAreas: ["Genetic Engineering": "CRISPR Technology", "Biomedical": "Drug Development"],
                facilities: ["Biotech Labs": "Molecular biology labs", "Research Center": "Advanced research facilities"],
                collaborations: ["Pharmaceutical Companies": "Dr. Reddy's, Biocon", "Research Institutes": "CSIR, ICMR"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
            ),
            Department(
                id: 8,
                school: 1,
                departmentName: "Applied Sciences",
                departmentCode: "AS",
                departmentType: "Science",
                hod: 8,
                researchAreas: ["Physics": "Quantum Mechanics", "Chemistry": "Organic Chemistry", "Mathematics": "Applied Mathematics"],
                facilities: ["Science Labs": "Physics and Chemistry labs", "Research Facilities": "Advanced research equipment"],
                collaborations: ["Research Organizations": "CSIR, DST", "Universities": "IITs, IISc"],
                createdAt: "2025-08-06T17:30:00.000Z",
                updatedAt: "2025-08-06T17:30:00.000Z"
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