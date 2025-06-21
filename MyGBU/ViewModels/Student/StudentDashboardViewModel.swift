import Foundation
import Combine

// MARK: - Student Dashboard ViewModel
class StudentDashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStudent: Student?
    
    // Dashboard Data
    @Published var attendanceOverview: AttendanceOverview?
    @Published var upcomingAssignments: [Assignment] = []
    @Published var recentNotices: [Notice] = []
    @Published var registrationStatus: RegistrationStatus?
    
    // UI State
    @Published var greetingMessage: String = ""
    @Published var showExpandedIDCard = false
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = StudentAPIService()
    
    init() {
        setupGreetingMessage()
    }
    
    // MARK: - Load Dashboard Data
    func loadDashboardData() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Replace with actual API calls when backend is ready
        loadMockData()
    }
    
    // MARK: - Mock Data (Remove when API is ready)
    private func loadMockData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentStudent = self.createMockStudent()
            self.attendanceOverview = self.createMockAttendance()
            self.upcomingAssignments = self.createMockAssignments()
            self.recentNotices = self.createMockNotices()
            self.registrationStatus = self.createMockRegistrationStatus()
            self.isLoading = false
        }
    }
    
    // MARK: - Greeting Message
    private func setupGreetingMessage() {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening"
        greetingMessage = greeting
    }
    
    // MARK: - ID Card Actions
    func showIDCard() {
        showExpandedIDCard = true
    }
    
    func hideIDCard() {
        showExpandedIDCard = false
    }
    
    // MARK: - Quick Actions
    func refreshAttendance() {
        // TODO: Implement API call
        print("Refreshing attendance...")
    }
    
    func refreshAssignments() {
        // TODO: Implement API call
        print("Refreshing assignments...")
    }
    
    func refreshNotices() {
        // TODO: Implement API call
        print("Refreshing notices...")
    }
}

// MARK: - Mock Data Creation (Remove when API is ready)
extension StudentDashboardViewModel {
    private func createMockStudent() -> Student {
        let user = User(
            id: "STU245UAI130",
            userType: .student,
            email: "yaduraj.singh@gbu.ac.in",
            firstName: "Yaduraj",
            lastName: "Singh",
            profileImageURL: nil,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return Student(
            id: "STU245UAI130",
            enrollmentNumber: "245uai130",
            user: user,
            course: "B.Tech",
            branch: "Information Technology",
            semester: 6,
            year: 3,
            section: "A",
            rollNumber: "245UAI130",
            admissionDate: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 2006, month: 8, day: 5))!,
            phoneNumber: "+91 9876543210",
            address: Address(street: "SOICT Campus", city: "Greater Noida", state: "UP", pincode: "201310", country: "India"),
            guardianInfo: GuardianInfo(name: "Sujeet Kumar Singh", relationship: "Father", phoneNumber: "+91 9876543211", email: "sujeet.singh@email.com", occupation: "Professional"),
            academicInfo: AcademicInfo(cgpa: 8.7, totalCredits: 180, completedCredits: 120, backlogs: 0, attendance: 88.5)
        )
    }
    
    private func createMockAttendance() -> AttendanceOverview {
        return AttendanceOverview(
            overallPercentage: 85.5,
            totalClasses: 120,
            attendedClasses: 102,
            subjectWiseAttendance: [
                SubjectAttendance(subjectName: "Data Structures", percentage: 90.0, attended: 18, total: 20),
                SubjectAttendance(subjectName: "Operating Systems", percentage: 82.5, attended: 16, total: 20),
                SubjectAttendance(subjectName: "Database Systems", percentage: 88.0, attended: 22, total: 25)
            ]
        )
    }
    
    private func createMockAssignments() -> [Assignment] {
        return [
            Assignment(id: "ASG001", title: "Data Structure Implementation", subject: "Data Structures", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, status: .pending, priority: .high),
            Assignment(id: "ASG002", title: "OS Process Scheduling", subject: "Operating Systems", dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, status: .pending, priority: .medium),
            Assignment(id: "ASG003", title: "Database Design Project", subject: "Database Systems", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, status: .pending, priority: .low)
        ]
    }
    
    private func createMockNotices() -> [Notice] {
        return [
            Notice(id: "NOT001", title: "Mid-Semester Exam Schedule", content: "Mid-semester examinations will be conducted from March 15-25, 2024.", date: Date(), priority: .high, category: .academic),
            Notice(id: "NOT002", title: "Library Timing Update", content: "Library will remain open till 10 PM during exam period.", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, priority: .medium, category: .general),
            Notice(id: "NOT003", title: "Hostel Fee Payment", content: "Hostel fee payment deadline is March 31, 2024.", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, priority: .high, category: .finance)
        ]
    }
    
    private func createMockRegistrationStatus() -> RegistrationStatus {
        return RegistrationStatus(
            isRegistrationOpen: true,
            semester: 7,
            registrationDeadline: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            maxCredits: 24,
            minCredits: 18,
            registeredCredits: 0,
            availableSubjects: []
        )
    }
}

// MARK: - Supporting Models for Dashboard
struct AttendanceOverview: Codable {
    let overallPercentage: Double
    let totalClasses: Int
    let attendedClasses: Int
    let subjectWiseAttendance: [SubjectAttendance]
}

struct SubjectAttendance: Codable, Identifiable {
    let id: UUID
    let subjectName: String
    let percentage: Double
    let attended: Int
    let total: Int
    
    init(subjectName: String, percentage: Double, attended: Int, total: Int) {
        self.id = UUID()
        self.subjectName = subjectName
        self.percentage = percentage
        self.attended = attended
        self.total = total
    }
}

struct Assignment: Codable, Identifiable {
    let id: String
    let title: String
    let subject: String
    let dueDate: Date
    let status: AssignmentStatus
    let priority: AssignmentPriority
}

enum AssignmentStatus: String, Codable {
    case pending = "pending"
    case submitted = "submitted"
    case overdue = "overdue"
}

enum AssignmentPriority: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

struct Notice: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let date: Date
    let priority: NoticePriority
    let category: NoticeCategory
}

enum NoticePriority: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
}

enum NoticeCategory: String, Codable {
    case academic = "academic"
    case general = "general"
    case finance = "finance"
    case hostel = "hostel"
}

struct RegistrationStatus: Codable {
    let isRegistrationOpen: Bool
    let semester: Int
    let registrationDeadline: Date
    let maxCredits: Int
    let minCredits: Int
    let registeredCredits: Int
    let availableSubjects: [Subject]
}

// MARK: - API Service (Placeholder for future implementation)
class StudentAPIService {
    private let baseURL = "" // TODO: Add actual API URL
    
    func fetchStudentData() -> AnyPublisher<Student, Error> {
        // TODO: Implement actual API call
        return Just(Student(
            id: "", enrollmentNumber: "", user: User(id: "", userType: .student, email: "", firstName: "", lastName: "", profileImageURL: nil, isActive: true, createdAt: Date(), updatedAt: Date()),
            course: "", branch: "", semester: 0, year: 0, section: nil, rollNumber: "", admissionDate: Date(), dateOfBirth: Date(), phoneNumber: "",
            address: Address(street: "", city: "", state: "", pincode: "", country: ""),
            guardianInfo: GuardianInfo(name: "", relationship: "", phoneNumber: "", email: nil, occupation: nil),
            academicInfo: AcademicInfo(cgpa: nil, totalCredits: 0, completedCredits: 0, backlogs: 0, attendance: 0.0)
        ))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func fetchAttendance() -> AnyPublisher<AttendanceOverview, Error> {
        // TODO: Implement actual API call
        return Just(AttendanceOverview(overallPercentage: 0, totalClasses: 0, attendedClasses: 0, subjectWiseAttendance: []))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAssignments() -> AnyPublisher<[Assignment], Error> {
        // TODO: Implement actual API call
        return Just([Assignment]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchNotices() -> AnyPublisher<[Notice], Error> {
        // TODO: Implement actual API call
        return Just([Notice]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 