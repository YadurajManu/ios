import Foundation
import SwiftUI

// MARK: - Academic Structure Models (Based on ERP Data Structure)

// MARK: - University & Organization Models
struct University: Codable, Identifiable {
    let id: String // university_id from ERP
    let universityName: String
    let universityCode: String
    let establishmentYear: String
    let accreditation: String
    let address: String
    let contactInfo: String
    let website: String
    let governanceStructure: [String]
    let policies: [String]
    let createdAt: Date
    let updatedAt: Date
}

struct School: Codable, Identifiable {
    let id: Int // school_id from ERP
    let university: Int
    let schoolName: String
    let schoolCode: String
    let schoolType: String
    let establishmentYear: String
    let accreditation: String
    let dean: Int?
    let facilities: [String: String]
    let visionMission: [String: String]
    let createdAt: String
    let updatedAt: String
    let departments: [Department]?
    
    enum CodingKeys: String, CodingKey {
        case id, university, schoolName, schoolCode, schoolType, establishmentYear, accreditation, dean, facilities, visionMission, createdAt, updatedAt, departments
    }
}

struct Department: Codable, Identifiable {
    let id: Int // department_id from ERP
    let school: Int
    let departmentName: String
    let departmentCode: String
    let departmentType: String
    let hod: Int?
    let researchAreas: [String: String]
    let facilities: [String: String]
    let collaborations: [String: String]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, school, departmentName, departmentCode, departmentType, hod, researchAreas, facilities, collaborations, createdAt, updatedAt
    }
}

// MARK: - Program Model (Enhanced from ERP)
struct Program: Codable, Identifiable {
    let id: String // program_id from ERP
    let departmentId: String
    let programName: String
    let programCode: String
    let programType: ProgramType
    let degreeType: DegreeType
    let durationSemesters: Int
    let totalCredits: Int
    let eligibilityCriteria: Double
    let admissionRequirements: [String]
    let curriculumStructure: [String]
    let accreditation: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum ProgramType: String, Codable, CaseIterable {
        case undergraduate = "undergraduate"
        case postgraduate = "postgraduate"
        case doctoral = "doctoral"
        case diploma = "diploma"
        case certificate = "certificate"
        
        var displayName: String {
            switch self {
            case .undergraduate: return "Undergraduate"
            case .postgraduate: return "Postgraduate"
            case .doctoral: return "Doctoral"
            case .diploma: return "Diploma"
            case .certificate: return "Certificate"
            }
        }
    }
    
    enum DegreeType: String, Codable, CaseIterable {
        case btech = "B.Tech"
        case mtech = "M.Tech"
        case bca = "BCA"
        case mca = "MCA"
        case bba = "BBA"
        case mba = "MBA"
        case phd = "Ph.D"
        case bsc = "B.Sc"
        case msc = "M.Sc"
        
        var displayName: String { rawValue }
        
        var programType: ProgramType {
            switch self {
            case .btech, .bca, .bba, .bsc: return .undergraduate
            case .mtech, .mca, .mba, .msc: return .postgraduate
            case .phd: return .doctoral
            }
        }
    }
}

// MARK: - Semester Model (ERP Structure)
struct Semester: Codable, Identifiable {
    let id: String // semester_id from ERP
    let programId: String
    let semesterNumber: Int
    let semesterName: String
    let durationMonths: Int
    let minCredits: Int
    let maxCredits: Int
    let semesterStructure: [String]
    let academicYear: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var displayName: String {
        "Semester \(semesterNumber)"
    }
    
    var isEvenSemester: Bool {
        semesterNumber % 2 == 0
    }
}

// MARK: - Course Model (Enhanced from ERP)
struct Course: Codable, Identifiable {
    let id: String // course_id from ERP
    let semesterId: String
    let courseCode: String
    let courseName: String
    let courseType: CourseType
    let theoryCredits: Int
    let practicalCredits: Int
    let totalCredits: Int
    let prerequisites: [String] // course_ids of prerequisite courses
    let learningOutcomes: [String]
    let syllabusURL: String?
    let isElective: Bool
    let isActive: Bool
    let capacity: Int? // Maximum students allowed
    let enrolledCount: Int? // Current enrollment count
    let facultyId: String? // Assigned faculty
    let schedule: CourseSchedule?
    let createdAt: Date
    let updatedAt: Date
    
    enum CourseType: String, Codable, CaseIterable {
        case core = "core"
        case elective = "elective"
        case practical = "practical"
        case project = "project"
        case internship = "internship"
        case seminar = "seminar"
        
        var displayName: String {
            switch self {
            case .core: return "Core"
            case .elective: return "Elective"
            case .practical: return "Practical"
            case .project: return "Project"
            case .internship: return "Internship"
            case .seminar: return "Seminar"
            }
        }
        
        var color: Color {
            switch self {
            case .core: return .red
            case .elective: return .blue
            case .practical: return .green
            case .project: return .orange
            case .internship: return .purple
            case .seminar: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .core: return "star.fill"
            case .elective: return "hand.point.up.left.fill"
            case .practical: return "wrench.and.screwdriver.fill"
            case .project: return "folder.fill"
            case .internship: return "building.2.fill"
            case .seminar: return "person.3.fill"
            }
        }
    }
    
    var isFull: Bool {
        guard let capacity = capacity, let enrolled = enrolledCount else { return false }
        return enrolled >= capacity
    }
    
    var availableSeats: Int {
        guard let capacity = capacity, let enrolled = enrolledCount else { return 0 }
        return max(0, capacity - enrolled)
    }
}

// MARK: - Subject Model (Enhanced from ERP)
struct Subject: Codable, Identifiable {
    let id: String // subject_id from ERP
    let courseId: String
    let subjectCode: String
    let subjectName: String
    let subjectType: SubjectType
    let credits: Int
    let theoryHours: Int
    let practicalHours: Int
    let syllabusContent: [String]
    let referenceMaterials: [String]
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum SubjectType: String, Codable, CaseIterable {
        case theory = "theory"
        case practical = "practical"
        case tutorial = "tutorial"
        case seminar = "seminar"
        
        var displayName: String {
            switch self {
            case .theory: return "Theory"
            case .practical: return "Practical"
            case .tutorial: return "Tutorial"
            case .seminar: return "Seminar"
            }
        }
        
        var icon: String {
            switch self {
            case .theory: return "book.fill"
            case .practical: return "wrench.and.screwdriver.fill"
            case .tutorial: return "person.2.fill"
            case .seminar: return "person.3.fill"
            }
        }
    }
}

// MARK: - Lab Model (ERP Structure)
struct Lab: Codable, Identifiable {
    let id: String // lab_id from ERP
    let courseId: String
    let labCode: String
    let labName: String
    let credits: Int
    let practicalHours: Int
    let equipmentRequired: [String]
    let experimentList: [String]
    let labManualURL: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Course Schedule Model
struct CourseSchedule: Codable {
    let dayOfWeek: [DayOfWeek]
    let startTime: String // "09:00"
    let endTime: String // "10:30"
    let room: String?
    let building: String?
    
    enum DayOfWeek: String, Codable, CaseIterable {
        case monday = "monday"
        case tuesday = "tuesday"
        case wednesday = "wednesday"
        case thursday = "thursday"
        case friday = "friday"
        case saturday = "saturday"
        case sunday = "sunday"
        
        var displayName: String {
            switch self {
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            case .sunday: return "Sunday"
            }
        }
        
        var shortName: String {
            switch self {
            case .monday: return "Mon"
            case .tuesday: return "Tue"
            case .wednesday: return "Wed"
            case .thursday: return "Thu"
            case .friday: return "Fri"
            case .saturday: return "Sat"
            case .sunday: return "Sun"
            }
        }
    }
}

// MARK: - Faculty Course Assignment
struct FacultyCourseAssignment: Codable, Identifiable {
    let id: String // assignment_id from ERP
    let facultyId: String
    let courseId: String
    let semesterId: String
    let academicYear: String
    let roleType: FacultyRole
    let teachingLoad: TeachingLoad
    let createdAt: Date
    let updatedAt: Date
    
    enum FacultyRole: String, Codable, CaseIterable {
        case primary = "primary"
        case secondary = "secondary"
        case coordinator = "coordinator"
        case examiner = "examiner"
        
        var displayName: String {
            switch self {
            case .primary: return "Primary Instructor"
            case .secondary: return "Secondary Instructor"
            case .coordinator: return "Course Coordinator"
            case .examiner: return "Examiner"
            }
        }
    }
}

// MARK: - Teaching Load
struct TeachingLoad: Codable {
    let theoryHours: Int
    let practicalHours: Int
    let tutorialHours: Int
    let totalHours: Int
    
    var weeklyLoad: Double {
        Double(totalHours) / 16.0 // Assuming 16-week semester
    }
}

// MARK: - Academic Year
struct AcademicYear: Codable, Identifiable {
    let id: String
    let academicYear: String // "2024-25"
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let semesters: [Semester]
    
    var displayName: String {
        "Academic Year \(academicYear)"
    }
    
    var isCurrent: Bool {
        let now = Date()
        return isActive && now >= startDate && now <= endDate
    }
} 