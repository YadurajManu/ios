import Foundation
import Combine
import SwiftUI

// MARK: - Student Dashboard ViewModel
class StudentDashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStudent: Student?
    
    // Dashboard Data
    @Published var attendanceOverview: AttendanceOverview?
    @Published var attendanceHistory: [AttendanceRecord] = []
    @Published var leaveApplications: [LeaveApplication] = []
    @Published var upcomingAssignments: [Assignment] = []
    @Published var recentNotices: [Notice] = []
    @Published var registrationStatus: StudentRegistrationInfo?
    
    // Local Storage Keys
    private let leaveApplicationsKey = "saved_leave_applications"
    
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
            self.attendanceHistory = self.createMockAttendanceHistory()
            self.loadLeaveApplicationsFromStorage()
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
    
    // MARK: - Leave Application Actions
    func applyForLeave(leaveType: LeaveType, startDate: Date, endDate: Date, reason: String, attachmentURL: String? = nil) {
        guard let studentId = currentStudent?.id else { return }
        
        let newLeave = LeaveApplication(
            studentId: studentId,
            leaveType: leaveType,
            startDate: startDate,
            endDate: endDate,
            reason: reason,
            attachmentURL: attachmentURL
        )
        
        leaveApplications.insert(newLeave, at: 0)
        saveLeaveApplicationsToStorage()
        
        // TODO: Implement API call when ready
        // POST /api/leave/apply
        print("Leave application submitted for \(leaveType.displayName)")
    }
    
    func cancelLeaveApplication(_ leaveId: UUID) {
        if let index = leaveApplications.firstIndex(where: { $0.id == leaveId }) {
            var updatedLeave = leaveApplications[index]
            // Create a new leave with cancelled status (we'll need to modify the model)
            leaveApplications.remove(at: index)
            saveLeaveApplicationsToStorage()
        }
        
        // TODO: Implement API call when ready
        // PUT /api/leave/{id}/cancel
        print("Leave application cancelled")
    }
    
    // MARK: - Local Storage Methods
    private func saveLeaveApplicationsToStorage() {
        do {
            let data = try JSONEncoder().encode(leaveApplications)
            UserDefaults.standard.set(data, forKey: leaveApplicationsKey)
            print("✅ Leave applications saved to local storage")
        } catch {
            print("❌ Failed to save leave applications: \(error)")
        }
    }
    
    private func loadLeaveApplicationsFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: leaveApplicationsKey) else {
            print("📝 No saved leave applications found")
            leaveApplications = []
            return
        }
        
        do {
            leaveApplications = try JSONDecoder().decode([LeaveApplication].self, from: data)
            print("✅ Loaded \(leaveApplications.count) leave applications from local storage")
        } catch {
            print("❌ Failed to load leave applications: \(error)")
            leaveApplications = []
        }
    }
    
    func clearLeaveApplicationsStorage() {
        UserDefaults.standard.removeObject(forKey: leaveApplicationsKey)
        leaveApplications = []
        print("🗑️ Cleared all leave applications from storage")
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
        
        // Enhanced Mock Academic Goals
        let academicGoals = [
            AcademicGoal(
                id: UUID().uuidString,
                type: .academic,
                title: "Achieve 9.0+ CGPA",
                description: "Maintain excellent academic performance throughout the semester",
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
                priority: .high,
                status: .active,
                progress: 0.75,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!,
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: .career,
                title: "Secure Software Engineer Role",
                description: "Get placed in a top-tier tech company with competitive package",
                targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date())!,
                priority: .high,
                status: .active,
                progress: 0.45,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 1))!,
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: .skill,
                title: "Complete Advanced Data Structures",
                description: "Master advanced algorithms and data structures for competitive programming",
                targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                priority: .medium,
                status: .active,
                progress: 0.80,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 10))!,
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: .personal,
                title: "Improve Communication Skills",
                description: "Enhance public speaking and presentation abilities",
                targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())!,
                priority: .medium,
                status: .active,
                progress: 0.30,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 5))!,
                updatedDate: Date()
            )
        ]
        
        // Enhanced Mock Skills & Strengths
        let skillsStrengths = [
            Skill(
                id: UUID().uuidString,
                skillName: "Swift Programming",
                category: .technical,
                proficiencyLevel: .advanced,
                certifications: ["iOS Development Certification", "Swift Associate Certification"],
                lastUpdated: Date(),
                endorsements: 15,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Problem Solving",
                category: .analytical,
                proficiencyLevel: .expert,
                certifications: nil,
                lastUpdated: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                endorsements: 22,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Database Management",
                category: .technical,
                proficiencyLevel: .intermediate,
                certifications: ["MySQL Fundamentals", "PostgreSQL Basics"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                endorsements: 8,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Leadership",
                category: .soft,
                proficiencyLevel: .advanced,
                certifications: ["Leadership Excellence Program"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                endorsements: 12,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "UI/UX Design",
                category: .creative,
                proficiencyLevel: .intermediate,
                certifications: ["Google UX Design Certificate"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                endorsements: 6,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Python Programming",
                category: .technical,
                proficiencyLevel: .advanced,
                certifications: ["Python Professional Certification"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                endorsements: 18,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Data Analysis",
                category: .analytical,
                proficiencyLevel: .intermediate,
                certifications: ["Google Data Analytics Certificate"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
                endorsements: 9,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Team Collaboration",
                category: .soft,
                proficiencyLevel: .advanced,
                certifications: nil,
                lastUpdated: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                endorsements: 25,
                isVerified: false
            )
        ]
        
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
            academicInfo: AcademicInfo(cgpa: 8.7, totalCredits: 180, completedCredits: 120, backlogs: 0, attendance: 88.5),
            
            // NEW FIELDS FOR DATABASE ALIGNMENT
            batch: "2022-2026",
            registrationStatus: .active,
            academicGoals: academicGoals,
            skillsStrengths: skillsStrengths,
            createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            updatedAt: Date()
        )
    }
    
    private func createMockAttendance() -> AttendanceOverview {
        let subjects = [
            SubjectAttendance(subjectCode: "CS601", subjectName: "Design & Analysis of Algorithms", facultyName: "Dr. Priya Sharma", percentage: 92.5, attended: 37, total: 40, classType: .theory),
            SubjectAttendance(subjectCode: "CS602", subjectName: "Operating Systems", facultyName: "Prof. Rajesh Kumar", percentage: 78.0, attended: 39, total: 50, classType: .theory),
            SubjectAttendance(subjectCode: "CS603", subjectName: "Database Management Systems", facultyName: "Dr. Anita Singh", percentage: 85.7, attended: 42, total: 49, classType: .theory),
            SubjectAttendance(subjectCode: "CS604", subjectName: "Computer Networks", facultyName: "Dr. Vikram Gupta", percentage: 68.2, attended: 30, total: 44, classType: .theory),
            SubjectAttendance(subjectCode: "CS605", subjectName: "Software Engineering", facultyName: "Prof. Meera Patel", percentage: 88.9, attended: 40, total: 45, classType: .theory),
            SubjectAttendance(subjectCode: "CS606", subjectName: "Web Technologies Lab", facultyName: "Dr. Amit Verma", percentage: 95.0, attended: 38, total: 40, classType: .practical)
        ]
        
        let totalClasses = subjects.reduce(0) { $0 + $1.total }
        let attendedClasses = subjects.reduce(0) { $0 + $1.attended }
        let overallPercentage = Double(attendedClasses) / Double(totalClasses) * 100
        
        let status: AttendanceStatus
        if overallPercentage >= 85 {
            status = .excellent
        } else if overallPercentage >= 75 {
            status = .good
        } else if overallPercentage >= 65 {
            status = .warning
        } else {
            status = .critical
        }
        
        return AttendanceOverview(
            overallPercentage: overallPercentage,
            totalClasses: totalClasses,
            attendedClasses: attendedClasses,
            subjectWiseAttendance: subjects,
            requiredPercentage: 75.0,
            status: status,
            lastUpdated: Date()
        )
    }
    
    private func createMockAttendanceHistory() -> [AttendanceRecord] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            AttendanceRecord(date: today, subjectCode: "CS606", subjectName: "Web Technologies Lab", status: .present, classType: .practical, period: "9:00-11:00 AM", markedBy: "Dr. Amit Verma"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, subjectCode: "CS601", subjectName: "Design & Analysis of Algorithms", status: .present, classType: .theory, period: "11:00-12:00 PM", markedBy: "Dr. Priya Sharma"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, subjectCode: "CS605", subjectName: "Software Engineering", status: .present, classType: .theory, period: "2:00-3:00 PM", markedBy: "Prof. Meera Patel"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, subjectCode: "CS604", subjectName: "Computer Networks", status: .absent, classType: .theory, period: "10:00-11:00 AM", markedBy: "Dr. Vikram Gupta", remarks: "Medical Leave"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, subjectCode: "CS603", subjectName: "Database Management Systems", status: .present, classType: .theory, period: "3:00-4:00 PM", markedBy: "Dr. Anita Singh"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, subjectCode: "CS602", subjectName: "Operating Systems", status: .late, classType: .theory, period: "9:00-10:00 AM", markedBy: "Prof. Rajesh Kumar", remarks: "Arrived 15 mins late"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, subjectCode: "CS601", subjectName: "Design & Analysis of Algorithms", status: .present, classType: .theory, period: "11:00-12:00 PM", markedBy: "Dr. Priya Sharma"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -4, to: today)!, subjectCode: "CS606", subjectName: "Web Technologies Lab", status: .present, classType: .practical, period: "2:00-4:00 PM", markedBy: "Dr. Amit Verma"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, subjectCode: "CS605", subjectName: "Software Engineering", status: .present, classType: .theory, period: "10:00-11:00 AM", markedBy: "Prof. Meera Patel"),
            AttendanceRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, subjectCode: "CS603", subjectName: "Database Management Systems", status: .present, classType: .theory, period: "3:00-4:00 PM", markedBy: "Dr. Anita Singh")
            ]
    }
    

    
    private func createMockAssignments() -> [Assignment] {
        return [
            Assignment(id: "ASG001", title: "Data Structure Implementation", subject: "Data Structures", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, status: .pending, priority: .high),
            Assignment(id: "ASG002", title: "OS Process Scheduling", subject: "Operating Systems", dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, status: .pending, priority: .medium),
            Assignment(id: "ASG003", title: "Database Design Project", subject: "Database Systems", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, status: .pending, priority: .low),
            Assignment(id: "ASG004", title: "Network Security Analysis", subject: "Computer Networks", dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!, status: .pending, priority: .medium),
            Assignment(id: "ASG005", title: "Web Application Development", subject: "Web Technologies", dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, status: .overdue, priority: .high),
            Assignment(id: "ASG006", title: "Software Testing Report", subject: "Software Engineering", dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, status: .submitted, priority: .medium),
            Assignment(id: "ASG007", title: "Algorithm Complexity Analysis", subject: "Data Structures", dueDate: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, status: .pending, priority: .low),
            Assignment(id: "ASG008", title: "Database Optimization", subject: "Database Systems", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, status: .pending, priority: .high)
        ]
    }
    
    private func createMockNotices() -> [Notice] {
        return [
            Notice(id: "NOT001", title: "Mid-Semester Exam Schedule", content: "Mid-semester examinations will be conducted from March 15-25, 2024.", date: Date(), priority: .high, category: .academic),
            Notice(id: "NOT002", title: "Library Timing Update", content: "Library will remain open till 10 PM during exam period.", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, priority: .medium, category: .general),
            Notice(id: "NOT003", title: "Hostel Fee Payment", content: "Hostel fee payment deadline is March 31, 2024.", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, priority: .high, category: .finance)
        ]
    }
    
    private func createMockRegistrationStatus() -> StudentRegistrationInfo {
        return StudentRegistrationInfo(
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

// MARK: - Leave Application Models
struct LeaveApplication: Codable, Identifiable {
    let id: UUID
    let studentId: String
    let leaveType: LeaveType
    let startDate: Date
    let endDate: Date
    let reason: String
    let status: LeaveStatus
    let appliedDate: Date
    let approvedBy: String?
    let approvedDate: Date?
    let remarks: String?
    let attachmentURL: String?
    
    init(studentId: String, leaveType: LeaveType, startDate: Date, endDate: Date, reason: String, attachmentURL: String? = nil) {
        self.id = UUID()
        self.studentId = studentId
        self.leaveType = leaveType
        self.startDate = startDate
        self.endDate = endDate
        self.reason = reason
        self.status = .pending
        self.appliedDate = Date()
        self.approvedBy = nil
        self.approvedDate = nil
        self.remarks = nil
        self.attachmentURL = attachmentURL
    }
    
    var durationDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0 + 1
    }
}

enum LeaveType: String, Codable, CaseIterable {
    case medical = "medical"
    case personal = "personal"
    case emergency = "emergency"
    case family = "family"
    case academic = "academic"
    
    var displayName: String {
        switch self {
        case .medical: return "Medical Leave"
        case .personal: return "Personal Leave"
        case .emergency: return "Emergency Leave"
        case .family: return "Family Emergency"
        case .academic: return "Academic Leave"
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .personal: return "person.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .family: return "house.fill"
        case .academic: return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .personal: return .black
        case .emergency: return .orange
        case .family: return .black
        case .academic: return .black
        }
    }
}

enum LeaveStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .approved: return .black
        case .rejected: return .red
        case .cancelled: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .cancelled: return "minus.circle.fill"
        }
    }
}

// MARK: - Supporting Models for Dashboard
struct AttendanceOverview: Codable {
    let overallPercentage: Double
    let totalClasses: Int
    let attendedClasses: Int
    let subjectWiseAttendance: [SubjectAttendance]
    let requiredPercentage: Double
    let status: AttendanceStatus
    let lastUpdated: Date
}

struct SubjectAttendance: Codable, Identifiable {
    let id: UUID
    let subjectCode: String
    let subjectName: String
    let facultyName: String
    let percentage: Double
    let attended: Int
    let total: Int
    let status: AttendanceStatus
    let lastClass: Date?
    let nextClass: Date?
    let classType: ClassType
    
    init(subjectCode: String, subjectName: String, facultyName: String, percentage: Double, attended: Int, total: Int, classType: ClassType = .theory, lastClass: Date? = nil, nextClass: Date? = nil) {
        self.id = UUID()
        self.subjectCode = subjectCode
        self.subjectName = subjectName
        self.facultyName = facultyName
        self.percentage = percentage
        self.attended = attended
        self.total = total
        self.classType = classType
        self.lastClass = lastClass
        self.nextClass = nextClass
        
        // Auto-calculate status based on percentage
        if percentage >= 85 {
            self.status = .excellent
        } else if percentage >= 75 {
            self.status = .good
        } else if percentage >= 65 {
            self.status = .warning
        } else {
            self.status = .critical
        }
    }
}

enum AttendanceStatus: String, Codable {
    case excellent = "excellent"
    case good = "good" 
    case warning = "warning"
    case critical = "critical"
    
    var displayText: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .red
        case .good: return .red
        case .warning: return .red
        case .critical: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}

enum ClassType: String, Codable {
    case theory = "theory"
    case practical = "practical"
    case tutorial = "tutorial"
    
    var displayName: String {
        switch self {
        case .theory: return "Theory"
        case .practical: return "Practical"
        case .tutorial: return "Tutorial"
        }
    }
}

// MARK: - Attendance History Models
struct AttendanceRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let subjectCode: String
    let subjectName: String
    let status: AttendanceRecordStatus
    let classType: ClassType
    let period: String
    let markedBy: String
    let remarks: String?
    
    init(date: Date, subjectCode: String, subjectName: String, status: AttendanceRecordStatus, classType: ClassType, period: String, markedBy: String, remarks: String? = nil) {
        self.id = UUID()
        self.date = date
        self.subjectCode = subjectCode
        self.subjectName = subjectName
        self.status = status
        self.classType = classType
        self.period = period
        self.markedBy = markedBy
        self.remarks = remarks
    }
}

enum AttendanceRecordStatus: String, Codable, CaseIterable {
    case present = "present"
    case absent = "absent"
    case late = "late"
    case excused = "excused"
    
    var displayText: String {
        switch self {
        case .present: return "Present"
        case .absent: return "Absent"
        case .late: return "Late"
        case .excused: return "Excused"
        }
    }
    
    var color: Color {
        switch self {
        case .present: return Color.green
        case .absent: return Color.red
        case .late: return Color.orange
        case .excused: return Color.blue
        }
    }
    
    var icon: String {
        switch self {
        case .present: return "checkmark.circle.fill"
        case .absent: return "xmark.circle.fill"
        case .late: return "clock.fill"
        case .excused: return "questionmark.circle.fill"
        }
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

struct StudentRegistrationInfo: Codable {
    let isRegistrationOpen: Bool
    let semester: Int
    let registrationDeadline: Date
    let maxCredits: Int
    let minCredits: Int
    let registeredCredits: Int
    let availableSubjects: [Subject]
}

// MARK: - API Service (Moved to separate file: Services/StudentAPIService.swift) 