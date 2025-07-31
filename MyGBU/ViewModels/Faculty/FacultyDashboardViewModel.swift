import Foundation
import SwiftUI
import Combine

// MARK: - Faculty Dashboard ViewModel
class FacultyDashboardViewModel: ObservableObject {
    @Published var currentFaculty: Faculty?
    @Published var todaysClasses: [FacultyClass] = []
    @Published var subjects: [Subject] = []
    @Published var students: [Student] = []
    @Published var assignments: [FacultyAssignment] = []
    @Published var recentActivities: [FacultyActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed properties for quick stats
    var totalStudents: Int {
        Set(students.map { $0.id }).count
    }
    
    var pendingAssignments: Int {
        assignments.filter { $0.status == .needsGrading }.count
    }
    
    init() {
        generateMockData()
    }
    
    func loadFacultyData(faculty: Faculty?) {
        guard let faculty = faculty else { return }
        
        isLoading = true
        currentFaculty = faculty
        
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
        generateSubjects()
        generateTodaysClasses()
        generateStudents()
        generateAssignments()
        generateRecentActivities()
    }
    
    private func generateSubjects() {
        subjects = [
            Subject(
                id: "SUB001",
                courseId: "COURSE001",
                subjectCode: "CS301",
                subjectName: "Database Management Systems",
                subjectType: .theory,
                credits: 4,
                theoryHours: 3,
                practicalHours: 1,
                syllabusContent: ["Database Design", "SQL", "Normalization"],
                referenceMaterials: ["Database Systems", "SQL Guide"],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Subject(
                id: "SUB002",
                courseId: "COURSE001",
                subjectCode: "CS302",
                subjectName: "Computer Networks",
                subjectType: .theory,
                credits: 4,
                theoryHours: 3,
                practicalHours: 1,
                syllabusContent: ["Network Protocols", "TCP/IP", "Routing"],
                referenceMaterials: ["Computer Networks", "Network Protocols"],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Subject(
                id: "SUB003",
                courseId: "COURSE001",
                subjectCode: "CS303",
                subjectName: "Software Engineering",
                subjectType: .theory,
                credits: 3,
                theoryHours: 2,
                practicalHours: 1,
                syllabusContent: ["SDLC", "Requirements", "Design Patterns"],
                referenceMaterials: ["Software Engineering", "Design Patterns"],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Subject(
                id: "SUB004",
                courseId: "COURSE001",
                subjectCode: "CS304",
                subjectName: "Operating Systems",
                subjectType: .theory,
                credits: 4,
                theoryHours: 3,
                practicalHours: 1,
                syllabusContent: ["Process Management", "Memory Management", "File Systems"],
                referenceMaterials: ["Operating Systems", "OS Concepts"],
                isActive: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    private func generateTodaysClasses() {
        let calendar = Calendar.current
        let today = Date()
        
        todaysClasses = [
            FacultyClass(
                id: "CLASS001",
                subject: subjects[0],
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: today) ?? today,
                room: "Room 301",
                year: 3,
                section: "A",
                status: .upcoming
            ),
            FacultyClass(
                id: "CLASS002",
                subject: subjects[1],
                startTime: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today) ?? today,
                room: "Room 302",
                year: 3,
                section: "B",
                status: .ongoing
            ),
            FacultyClass(
                id: "CLASS003",
                subject: subjects[2],
                startTime: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 15, minute: 30, second: 0, of: today) ?? today,
                room: "Room 303",
                year: 3,
                section: "A",
                status: .upcoming
            )
        ]
    }
    
    private func generateStudents() {
        students = (1...45).map { index in
            Student(
                id: "STU\(String(format: "%03d", index))",
                enrollmentNumber: "2024\(String(format: "%03d", index))",
                user: User(
                    id: "USR\(String(format: "%03d", index))",
                    userType: .student,
                    email: "student\(index)@gbu.ac.in",
                    firstName: "Student",
                    lastName: "\(index)",
                    profileImageURL: nil,
                    isActive: true,
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                course: "B.Tech",
                branch: "Information Technology",
                semester: [5, 6].randomElement() ?? 6,
                year: 3,
                section: ["A", "B"].randomElement(),
                rollNumber: "2024IT\(String(format: "%03d", index))",
                admissionDate: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15)) ?? Date(),
                dateOfBirth: Calendar.current.date(from: DateComponents(year: 2005, month: 1, day: 1)) ?? Date(),
                phoneNumber: "+91 98765\(String(format: "%05d", 43200 + index))",
                address: Address(
                    street: "Student Housing Block \(index % 5 + 1)",
                    city: "Greater Noida",
                    state: "Uttar Pradesh",
                    pincode: "201310",
                    country: "India"
                ),
                guardianInfo: GuardianInfo(
                    name: "Guardian \(index)",
                    relationship: "Father",
                    phoneNumber: "+91 98765\(String(format: "%05d", 43200 + index + 1000))",
                    email: "guardian\(index)@email.com",
                    occupation: "Professional"
                ),
                academicInfo: AcademicInfo(
                    cgpa: Double.random(in: 6.0...9.5),
                    totalCredits: 140,
                    completedCredits: Int.random(in: 80...120),
                    backlogs: Int.random(in: 0...3),
                    attendance: Double.random(in: 70...95)
                ),
                batch: "2022-2026",
                registrationStatus: .active,
                academicGoals: nil,
                skillsStrengths: nil,
                createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15)) ?? Date(),
                updatedAt: Date()
            )
        }
    }
    
    private func generateAssignments() {
        assignments = [
            FacultyAssignment(
                id: "ASSIGN001",
                title: "Database Design Project",
                subject: subjects[0],
                description: "Design and implement a complete database for a library management system",
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                totalMarks: 100,
                status: .active,
                submissionCount: 25,
                gradedCount: 10,
                createdDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
            ),
            FacultyAssignment(
                id: "ASSIGN002",
                title: "Network Security Analysis",
                subject: subjects[1],
                description: "Analyze different network security protocols and their implementations",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                totalMarks: 50,
                status: .needsGrading,
                submissionCount: 30,
                gradedCount: 5,
                createdDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            ),
            FacultyAssignment(
                id: "ASSIGN003",
                title: "Software Development Lifecycle",
                subject: subjects[2],
                description: "Create a comprehensive report on SDLC methodologies",
                dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                totalMarks: 75,
                status: .graded,
                submissionCount: 28,
                gradedCount: 28,
                createdDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()
            )
        ]
    }
    
    private func generateRecentActivities() {
        recentActivities = [
            FacultyActivity(
                id: "ACT001",
                title: "Assignment Submitted",
                description: "5 new submissions for Database Design Project",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                icon: "doc.text.fill",
                color: Color.blue
            ),
            FacultyActivity(
                id: "ACT002",
                title: "Class Completed",
                description: "Computer Networks - Year 3 Section B",
                timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
                icon: "checkmark.circle.fill",
                color: Color.green
            ),
            FacultyActivity(
                id: "ACT003",
                title: "Grades Published",
                description: "Software Development Lifecycle assignment grades released",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                icon: "star.fill",
                color: Color.orange
            ),
            FacultyActivity(
                id: "ACT004",
                title: "Student Query",
                description: "3 students asked questions about upcoming exam",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                icon: "questionmark.circle.fill",
                color: Color.purple
            )
        ]
    }
}

// MARK: - Faculty Models
struct FacultyClass: Identifiable {
    let id: String
    let subject: Subject
    let startTime: Date
    let endTime: Date
    let room: String
    let year: Int
    let section: String
    let status: ClassStatus
}

enum ClassStatus: String, CaseIterable {
    case upcoming = "upcoming"
    case ongoing = "ongoing"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .ongoing: return "Ongoing"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .upcoming: return Color.blue
        case .ongoing: return Color.green
        case .completed: return Color.gray
        case .cancelled: return Color.red
        }
    }
}

struct FacultyAssignment: Identifiable {
    let id: String
    let title: String
    let subject: Subject
    let description: String
    let dueDate: Date
    let totalMarks: Int
    let status: FacultyAssignmentStatus
    let submissionCount: Int
    let gradedCount: Int
    let createdDate: Date
}

enum FacultyAssignmentStatus: String, CaseIterable {
    case draft = "draft"
    case active = "active"
    case needsGrading = "needs_grading"
    case graded = "graded"
    case archived = "archived"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .needsGrading: return "Needs Grading"
        case .graded: return "Graded"
        case .archived: return "Archived"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return Color.gray
        case .active: return Color.blue
        case .needsGrading: return Color.orange
        case .graded: return Color.green
        case .archived: return Color.purple
        }
    }
}

struct FacultyActivity: Identifiable {
    let id: String
    let title: String
    let description: String
    let timestamp: Date
    let icon: String
    let color: Color
} 