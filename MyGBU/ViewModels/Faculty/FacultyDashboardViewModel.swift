import Foundation
import SwiftUI
import Combine

// MARK: - Faculty Attendance Models
struct FacultyAttendanceRecord: Identifiable, Codable {
    let id: String
    let studentId: String
    let classId: String
    let subjectId: String
    let date: Date
    let status: AttendanceRecordStatus
    let markedBy: String // faculty ID
    let markedAt: Date
    let remarks: String?
}

struct ClassAttendance: Identifiable {
    let id: String
    let classId: String
    let subjectId: String
    let date: Date
    var students: [StudentAttendanceItem]
    let totalStudents: Int
    let presentCount: Int
    let absentCount: Int
    let lateCount: Int
    let excusedCount: Int
    
    var attendancePercentage: Double {
        guard totalStudents > 0 else { return 0.0 }
        return Double(presentCount + lateCount) / Double(totalStudents) * 100
    }
}

struct StudentAttendanceItem: Identifiable {
    let id: String
    let student: Student
    var status: AttendanceRecordStatus
    let cgpa: Double
    let currentAttendance: Double
    var remarks: String?
    var isMarked: Bool
}

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
    
    // Attendance related properties
    @Published var classAttendances: [ClassAttendance] = []
    @Published var selectedClassForAttendance: FacultyClass?
    @Published var isShowingAttendanceSheet = false
    
    // Computed properties for quick stats
    var totalStudents: Int {
        Set(students.map { $0.id }).count
    }
    
    var pendingAssignments: Int {
        assignments.filter { $0.status == .needsGrading }.count
    }
    
    var todaysAttendanceStats: (total: Int, marked: Int, percentage: Double) {
        let totalClasses = todaysClasses.count
        let markedClasses = classAttendances.filter { attendance in
            Calendar.current.isDate(attendance.date, inSameDayAs: Date()) &&
            todaysClasses.contains { $0.id == attendance.classId }
        }.count
        
        let percentage = totalClasses > 0 ? Double(markedClasses) / Double(totalClasses) * 100 : 0
        return (totalClasses, markedClasses, percentage)
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
    
    // MARK: - Attendance Methods
    func markAttendance(for classItem: FacultyClass) {
        selectedClassForAttendance = classItem
        isShowingAttendanceSheet = true
    }
    
    func getAttendanceForClass(_ classItem: FacultyClass) -> ClassAttendance? {
        return classAttendances.first { $0.classId == classItem.id }
    }
    
    func updateAttendanceStatus(studentId: String, classId: String, status: AttendanceRecordStatus, remarks: String? = nil) {
        // In a real app, this would make an API call
        // For now, we'll update the local data
        
        if let attendanceIndex = classAttendances.firstIndex(where: { $0.classId == classId }) {
            if let studentIndex = classAttendances[attendanceIndex].students.firstIndex(where: { $0.student.id == studentId }) {
                classAttendances[attendanceIndex].students[studentIndex].status = status
                classAttendances[attendanceIndex].students[studentIndex].remarks = remarks
                classAttendances[attendanceIndex].students[studentIndex].isMarked = true
                
                // Update counts
                updateAttendanceCounts(for: attendanceIndex)
            }
        }
        
        // Add to recent activities
        let student = students.first { $0.id == studentId }
        let activity = FacultyActivity(
            id: UUID().uuidString,
            title: "Attendance Marked",
            description: "\(student?.user.fullName ?? "Student") marked as \(status.displayText)",
            timestamp: Date(),
            icon: status.icon,
            color: status.color
        )
        recentActivities.insert(activity, at: 0)
        
        // Keep only last 10 activities
        if recentActivities.count > 10 {
            recentActivities = Array(recentActivities.prefix(10))
        }
    }
    
    private func updateAttendanceCounts(for attendanceIndex: Int) {
        let students = classAttendances[attendanceIndex].students
        let presentCount = students.filter { $0.status == .present }.count
        let absentCount = students.filter { $0.status == .absent }.count
        let lateCount = students.filter { $0.status == .late }.count
        let excusedCount = students.filter { $0.status == .excused }.count
        
        classAttendances[attendanceIndex] = ClassAttendance(
            id: classAttendances[attendanceIndex].id,
            classId: classAttendances[attendanceIndex].classId,
            subjectId: classAttendances[attendanceIndex].subjectId,
            date: classAttendances[attendanceIndex].date,
            students: students,
            totalStudents: students.count,
            presentCount: presentCount,
            absentCount: absentCount,
            lateCount: lateCount,
            excusedCount: excusedCount
        )
    }
    
    func submitAttendance(for classId: String) {
        // Find the class attendance data
        guard let attendanceIndex = classAttendances.firstIndex(where: { $0.classId == classId }) else {
            print("❌ Attendance data not found for class: \(classId)")
            return
        }
        
        let attendance = classAttendances[attendanceIndex]
        
        // Calculate attendance statistics
        let totalStudents = attendance.students.count
        let presentCount = attendance.students.filter { $0.status == .present }.count
        let absentCount = attendance.students.filter { $0.status == .absent }.count
        let lateCount = attendance.students.filter { $0.status == .late }.count
        let excusedCount = attendance.students.filter { $0.status == .excused }.count
        
        let attendancePercentage = totalStudents > 0 ? Double(presentCount) / Double(totalStudents) * 100 : 0
        
        // Mark all students as marked
        var updatedStudents = attendance.students
        for i in 0..<updatedStudents.count {
            updatedStudents[i].isMarked = true
        }
        
        // Update the attendance data
        let updatedAttendance = ClassAttendance(
            id: attendance.id,
            classId: attendance.classId,
            subjectId: attendance.subjectId,
            date: attendance.date,
            students: updatedStudents,
            totalStudents: totalStudents,
            presentCount: presentCount,
            absentCount: absentCount,
            lateCount: lateCount,
            excusedCount: excusedCount
        )
        
        classAttendances[attendanceIndex] = updatedAttendance
        
        // Update the class status to completed
        if let classIndex = todaysClasses.firstIndex(where: { $0.id == classId }) {
            let updatedClass = FacultyClass(
                id: todaysClasses[classIndex].id,
                subject: todaysClasses[classIndex].subject,
                startTime: todaysClasses[classIndex].startTime,
                endTime: todaysClasses[classIndex].endTime,
                room: todaysClasses[classIndex].room,
                year: todaysClasses[classIndex].year,
                section: todaysClasses[classIndex].section,
                status: .completed
            )
            todaysClasses[classIndex] = updatedClass
        }
        
        // Add to recent activities with detailed information
        let activity = FacultyActivity(
            id: UUID().uuidString,
            title: "Attendance Submitted",
            description: "\(attendance.subjectId) - \(presentCount) present, \(absentCount) absent (\(Int(attendancePercentage))%)",
            timestamp: Date(),
            icon: "checkmark.circle.fill",
            color: attendancePercentage >= 80 ? Color.green : attendancePercentage >= 60 ? Color.orange : Color.red
        )
        recentActivities.insert(activity, at: 0)
        
        // Close the attendance sheet
        isShowingAttendanceSheet = false
        selectedClassForAttendance = nil
        
        print("✅ Attendance submitted successfully for class \(classId)")
        print("📊 Statistics: \(presentCount) present, \(absentCount) absent, \(lateCount) late, \(excusedCount) excused")
        print("📈 Attendance percentage: \(Int(attendancePercentage))%")
    }
    
    // MARK: - Mock Data Generation
    private func generateMockData() {
        generateSubjects()
        generateTodaysClasses()
        generateStudents()
        generateAssignments()
        generateRecentActivities()
        generateAttendanceData()
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
        // Realistic Indian names for students
        let indianFirstNames = [
            "Aarav", "Arjun", "Advait", "Aryan", "Dhruv", "Ishaan", "Krishna", "Lakshay", "Mihir", "Neel",
            "Pranav", "Reyansh", "Shaurya", "Vedant", "Yash", "Zain", "Aditya", "Bhavesh", "Chirag", "Devansh",
            "Esha", "Fatima", "Gauri", "Harshita", "Ishita", "Jiya", "Kavya", "Lakshmi", "Mira", "Nisha",
            "Priya", "Riya", "Saanvi", "Tara", "Uma", "Vanya", "Zara", "Ananya", "Bhavya", "Charvi",
            "Disha", "Eva", "Fiza", "Gayatri", "Himanshi", "Ira", "Jhanvi", "Kashvi", "Lavanya", "Mishka"
        ]
        
        let indianLastNames = [
            "Sharma", "Verma", "Patel", "Kumar", "Singh", "Gupta", "Malhotra", "Kapoor", "Joshi", "Chopra",
            "Reddy", "Mehra", "Tiwari", "Yadav", "Kaur", "Khan", "Ali", "Hussain", "Ahmed", "Khan",
            "Rajput", "Chauhan", "Tomar", "Rathore", "Solanki", "Parmar", "Bhatt", "Pandey", "Mishra", "Tiwari",
            "Dubey", "Trivedi", "Shukla", "Dwivedi", "Saxena", "Agarwal", "Jain", "Goyal", "Bansal", "Goel",
            "Khanna", "Sethi", "Soni", "Bhatia", "Chawla", "Gill", "Dhillon", "Sidhu", "Brar", "Sandhu"
        ]
        
        students = (1...45).map { index in
            let firstName = indianFirstNames[index % indianFirstNames.count]
            let lastName = indianLastNames[index % indianLastNames.count]
            let fullName = "\(firstName) \(lastName)"
            
            // Generate realistic enrollment number (format: YYYYBRANCHXXX)
            let enrollmentNumber = "2024IT\(String(format: "%03d", index))"
            
            // Generate realistic roll number
            let rollNumber = "2024IT\(String(format: "%03d", index))"
            
            // Generate realistic phone numbers
            let phoneNumber = "+91 98765\(String(format: "%05d", 43200 + index))"
            let guardianPhone = "+91 98765\(String(format: "%05d", 43200 + index + 1000))"
            
            // Generate realistic academic data
            let cgpa = Double.random(in: 6.5...9.8)
            let attendance = Double.random(in: 75...98)
            let completedCredits = Int.random(in: 85...125)
            let backlogs = Int.random(in: 0...2)
            
            // Generate realistic address
            let addressBlocks = ["A", "B", "C", "D", "E"]
            let addressBlock = addressBlocks[index % addressBlocks.count]
            let roomNumber = (index % 20) + 101
            
            return Student(
                id: "STU\(String(format: "%03d", index))",
                enrollmentNumber: enrollmentNumber,
                user: User(
                    id: "USR\(String(format: "%03d", index))",
                    userType: .student,
                    email: "\(firstName.lowercased()).\(lastName.lowercased())@gbu.ac.in",
                    firstName: firstName,
                    lastName: lastName,
                    profileImageURL: nil,
                    isActive: true,
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                course: "B.Tech",
                branch: "Information Technology",
                semester: [5, 6].randomElement() ?? 6,
                year: 3,
                section: ["A", "B"].randomElement() ?? "A",
                rollNumber: rollNumber,
                admissionDate: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15)) ?? Date(),
                dateOfBirth: Calendar.current.date(from: DateComponents(year: 2005, month: Int.random(in: 1...12), day: Int.random(in: 1...28))) ?? Date(),
                phoneNumber: phoneNumber,
                address: Address(
                    street: "Room \(roomNumber), Block \(addressBlock)",
                    city: "Greater Noida",
                    state: "Uttar Pradesh",
                    pincode: "201310",
                    country: "India"
                ),
                guardianInfo: GuardianInfo(
                    name: "\(lastName) \(firstName)",
                    relationship: ["Father", "Mother", "Guardian"].randomElement() ?? "Father",
                    phoneNumber: guardianPhone,
                    email: "\(lastName.lowercased())\(firstName.lowercased())@email.com",
                    occupation: ["Engineer", "Doctor", "Teacher", "Business Owner", "Government Employee"].randomElement() ?? "Professional"
                ),
                academicInfo: AcademicInfo(
                    cgpa: cgpa,
                    totalCredits: 140,
                    completedCredits: completedCredits,
                    backlogs: backlogs,
                    attendance: attendance
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
                detailedInstructions: "Create a detailed ER diagram for the library management system. Include all necessary tables, relationships, and constraints. Use SQL to create the database schema. Submit a PDF report.",
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                totalMarks: 100,
                status: .active,
                submissionCount: 25,
                gradedCount: 10,
                createdDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                assignmentType: .project,
                allowedFileTypes: ["pdf"],
                maxFileSize: 10,
                isGroupAssignment: false,
                maxGroupSize: nil,
                rubric: [
                    AssignmentRubric(id: UUID().uuidString, criteria: "Database Design", maxPoints: 50, description: "Proper ER diagram with all necessary tables and relationships."),
                    AssignmentRubric(id: UUID().uuidString, criteria: "SQL Schema", maxPoints: 50, description: "Correctly implemented SQL schema for the database.")
                ],
                attachments: [],
                targetYear: 3,
                targetSection: "A",
                lateSubmissionAllowed: false,
                lateSubmissionPenalty: 0.0,
                plagiarismCheckEnabled: true
            ),
            FacultyAssignment(
                id: "ASSIGN002",
                title: "Network Security Analysis",
                subject: subjects[1],
                description: "Analyze different network security protocols and their implementations",
                detailedInstructions: "Research and write a report on the following protocols: TCP/IP, SSL/TLS, SSH, and VPN. Discuss their purpose, advantages, and disadvantages. Include diagrams where applicable.",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                totalMarks: 50,
                status: .needsGrading,
                submissionCount: 30,
                gradedCount: 5,
                createdDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                assignmentType: .report,
                allowedFileTypes: ["pdf", "docx"],
                maxFileSize: 5,
                isGroupAssignment: true,
                maxGroupSize: 3,
                rubric: [
                    AssignmentRubric(id: UUID().uuidString, criteria: "Research Depth", maxPoints: 20, description: "Comprehensive research on the protocols, including diagrams and examples."),
                    AssignmentRubric(id: UUID().uuidString, criteria: "Analysis Clarity", maxPoints: 30, description: "Clear and well-structured analysis of advantages and disadvantages.")
                ],
                attachments: [],
                targetYear: 3,
                targetSection: "B",
                lateSubmissionAllowed: true,
                lateSubmissionPenalty: 5.0,
                plagiarismCheckEnabled: true
            ),
            FacultyAssignment(
                id: "ASSIGN003",
                title: "Software Development Lifecycle",
                subject: subjects[2],
                description: "Create a comprehensive report on SDLC methodologies",
                detailedInstructions: "Write a detailed report on the Waterfall, Agile, and DevOps SDLC methodologies. Discuss their pros and cons, and provide a real-world example for each.",
                dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                totalMarks: 75,
                status: .graded,
                submissionCount: 28,
                gradedCount: 28,
                createdDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
                assignmentType: .report,
                allowedFileTypes: ["pdf", "docx"],
                maxFileSize: 10,
                isGroupAssignment: false,
                maxGroupSize: nil,
                rubric: [
                    AssignmentRubric(id: UUID().uuidString, criteria: "Methodology Understanding", maxPoints: 30, description: "Comprehensive understanding of the three methodologies."),
                    AssignmentRubric(id: UUID().uuidString, criteria: "Pros and Cons", maxPoints: 45, description: "Clear and well-structured analysis of pros and cons for each methodology.")
                ],
                attachments: [],
                targetYear: 3,
                targetSection: "A",
                lateSubmissionAllowed: true,
                lateSubmissionPenalty: 10.0,
                plagiarismCheckEnabled: true
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
    
    private func generateAttendanceData() {
        // Generate attendance data for today's classes
        classAttendances = todaysClasses.map { classItem in
            let classStudents = students.filter { student in
                // Filter students based on year and section
                student.year == classItem.year && student.section == classItem.section
            }
            
            let studentAttendanceItems = classStudents.map { student in
                // Generate more realistic attendance status based on student's attendance history
                let attendanceStatus: AttendanceRecordStatus
                let randomValue = Double.random(in: 0...1)
                
                // Students with higher attendance are more likely to be present
                let attendanceProbability = student.academicInfo.attendance / 100.0
                
                if randomValue < attendanceProbability * 0.8 {
                    // High probability of being present for students with good attendance
                    attendanceStatus = .present
                } else if randomValue < attendanceProbability * 0.9 {
                    // Some students might be late
                    attendanceStatus = .late
                } else if randomValue < attendanceProbability * 0.95 {
                    // Few students might be excused
                    attendanceStatus = .excused
                } else {
                    // Low probability of being absent
                    attendanceStatus = .absent
                }
                
                // Add some remarks for absent/late students
                let remarks: String?
                switch attendanceStatus {
                case .absent:
                    remarks = ["Medical emergency", "Family function", "Transport issue", "Personal emergency"].randomElement()
                case .late:
                    remarks = ["Traffic delay", "Missed bus", "Overslept", "Previous class ran late"].randomElement()
                case .excused:
                    remarks = ["Official leave", "Sports event", "Cultural program", "Medical appointment"].randomElement()
                case .present:
                    remarks = nil
                }
                
                return StudentAttendanceItem(
                    id: UUID().uuidString,
                    student: student,
                    status: attendanceStatus,
                    cgpa: student.academicInfo.cgpa ?? 0.0,
                    currentAttendance: student.academicInfo.attendance,
                    remarks: remarks,
                    isMarked: false // Initially not marked, will be marked when faculty updates
                )
            }
            
            let presentCount = studentAttendanceItems.filter { $0.status == .present }.count
            let absentCount = studentAttendanceItems.filter { $0.status == .absent }.count
            let lateCount = studentAttendanceItems.filter { $0.status == .late }.count
            let excusedCount = studentAttendanceItems.filter { $0.status == .excused }.count
            
            return ClassAttendance(
                id: UUID().uuidString,
                classId: classItem.id,
                subjectId: classItem.subject.id,
                date: Date(),
                students: studentAttendanceItems,
                totalStudents: studentAttendanceItems.count,
                presentCount: presentCount,
                absentCount: absentCount,
                lateCount: lateCount,
                excusedCount: excusedCount
            )
        }
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
    let detailedInstructions: String
    let dueDate: Date
    let totalMarks: Int
    let status: FacultyAssignmentStatus
    let submissionCount: Int
    let gradedCount: Int
    let createdDate: Date
    let assignmentType: AssignmentType
    let allowedFileTypes: [String]
    let maxFileSize: Int // in MB
    let isGroupAssignment: Bool
    let maxGroupSize: Int?
    let rubric: [AssignmentRubric]
    let attachments: [AssignmentAttachment]
    let targetYear: Int
    let targetSection: String
    let lateSubmissionAllowed: Bool
    let lateSubmissionPenalty: Double // percentage deduction
    let plagiarismCheckEnabled: Bool
}

enum AssignmentType: String, CaseIterable {
    case individual = "individual"
    case group = "group"
    case presentation = "presentation"
    case project = "project"
    case quiz = "quiz"
    case report = "report"
    
    var displayName: String {
        switch self {
        case .individual: return "Individual"
        case .group: return "Group"
        case .presentation: return "Presentation"
        case .project: return "Project"
        case .quiz: return "Quiz"
        case .report: return "Report"
        }
    }
    
    var icon: String {
        switch self {
        case .individual: return "person.fill"
        case .group: return "person.3.fill"
        case .presentation: return "presentation"
        case .project: return "folder.fill"
        case .quiz: return "questionmark.circle.fill"
        case .report: return "doc.text.fill"
        }
    }
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

struct AssignmentRubric: Identifiable {
    let id: String
    let criteria: String
    let maxPoints: Int
    let description: String
}

struct AssignmentAttachment: Identifiable {
    let id: String
    let fileName: String
    let fileSize: Int
    let fileType: String
    let uploadDate: Date
}

struct FacultyActivity: Identifiable {
    let id: String
    let title: String
    let description: String
    let timestamp: Date
    let icon: String
    let color: Color
} 