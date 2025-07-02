import Foundation
import SwiftUI

// MARK: - User Types
enum UserType: String, CaseIterable, Codable {
    case student = "student"
    case faculty = "faculty"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .student: return "Student"
        case .faculty: return "Faculty"
        case .admin: return "Admin"
        }
    }
    
    var icon: String {
        switch self {
        case .student: return "graduationcap.fill"
        case .faculty: return "person.fill.badge.plus"
        case .admin: return "shield.fill"
        }
    }
}

// MARK: - Base User Model
struct User: Codable, Identifiable {
    let id: String
    let userType: UserType
    let email: String
    let firstName: String
    let lastName: String
    let profileImageURL: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Student Model
struct Student: Codable, Identifiable {
    let id: String
    let enrollmentNumber: String
    let user: User
    let course: String // Maps to 'program' in database
    let branch: String
    let semester: Int // Maps to 'current_semester' in database
    let year: Int
    let section: String?
    let rollNumber: String
    let admissionDate: Date
    let dateOfBirth: Date
    let phoneNumber: String
    let address: Address
    let guardianInfo: GuardianInfo
    let academicInfo: AcademicInfo
    
    // NEW FIELDS FOR DATABASE ALIGNMENT
    let batch: String // e.g., "2022-2026"
    let registrationStatus: RegistrationStatus
    let academicGoals: [AcademicGoal]?
    let skillsStrengths: [Skill]?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Faculty Model
struct Faculty: Codable, Identifiable {
    let id: String
    let employeeId: String
    let user: User
    let department: String
    let designation: String
    let joiningDate: Date
    let qualification: [String]
    let specialization: [String]
    let phoneNumber: String
    let officeLocation: String?
    let subjects: [Subject]
}

// MARK: - Admin Model
struct Admin: Codable, Identifiable {
    let id: String
    let employeeId: String
    let user: User
    let department: String
    let role: AdminRole
    let permissions: [Permission]
    let joiningDate: Date
}

// MARK: - Supporting Models
struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let pincode: String
    let country: String
}

struct GuardianInfo: Codable {
    let name: String
    let relationship: String
    let phoneNumber: String
    let email: String?
    let occupation: String?
}

struct AcademicInfo: Codable {
    let cgpa: Double?
    let totalCredits: Int
    let completedCredits: Int
    let backlogs: Int
    let attendance: Double
}

struct Subject: Codable, Identifiable {
    let id: String
    let code: String
    let name: String
    let credits: Int
    let semester: Int
}

enum AdminRole: String, Codable, CaseIterable {
    case superAdmin = "super_admin"
    case academicAdmin = "academic_admin"
    case financeAdmin = "finance_admin"
    case libraryAdmin = "library_admin"
    case hostelAdmin = "hostel_admin"
    
    var displayName: String {
        switch self {
        case .superAdmin: return "Super Admin"
        case .academicAdmin: return "Academic Admin"
        case .financeAdmin: return "Finance Admin"
        case .libraryAdmin: return "Library Admin"
        case .hostelAdmin: return "Hostel Admin"
        }
    }
}

struct Permission: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let module: String
}

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let refresh: String
    let access: String
}

struct TokenRefreshRequest: Codable {
    let refresh: String
}

struct TokenRefreshResponse: Codable {
    let access: String
}

struct ProtectedResponse: Codable {
    let message: String
}

// MARK: - JWT User Info Model
struct JWTUserInfo {
    let userId: Int
    let email: String
    let userType: UserType
}

// Legacy models for backward compatibility
struct LegacyLoginRequest: Codable {
    let enrollmentNumber: String?
    let employeeId: String?
    let password: String
    let userType: UserType
}

struct LegacyLoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let user: User?
    let student: Student?
    let faculty: Faculty?
    let admin: Admin?
    let expiresAt: Date?
}

// MARK: - Registration Models
struct RegistrationRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phone: String
    let userType: String
    
    private enum CodingKeys: String, CodingKey {
        case email, password, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case userType = "user_type"
    }
}

struct RegistrationResponse: Codable {
    let message: String
}

struct RegistrationErrorResponse: Codable {
    let email: [String]?
    let message: String?
}

// MARK: - Assignment Submission Models
struct AssignmentSubmission: Codable, Identifiable {
    let id: String
    let assignmentId: String
    let studentId: String
    let submissionText: String
    let attachedFiles: [SubmissionFile]
    let submittedAt: Date
    let status: SubmissionStatus
    let grade: Double?
    let feedback: String?
    let gradedAt: Date?
    let gradedBy: String? // Faculty ID
    let submissionNumber: Int // For tracking multiple attempts
    let isLateSubmission: Bool
    let plagiarismScore: Double?
}

struct SubmissionFile: Codable, Identifiable {
    let id: String
    let fileName: String
    let originalFileName: String
    let fileSize: Int64
    let mimeType: String
    let fileURL: String
    let uploadedAt: Date
    let checksum: String?
}

enum SubmissionStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case submitted = "submitted"
    case underReview = "under_review"
    case graded = "graded"
    case returned = "returned"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .submitted: return "Submitted"
        case .underReview: return "Under Review"
        case .graded: return "Graded"
        case .returned: return "Returned"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return .gray
        case .submitted: return .blue
        case .underReview: return .orange
        case .graded: return .green
        case .returned: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .draft: return "doc.text"
        case .submitted: return "paperplane.fill"
        case .underReview: return "clock.fill"
        case .graded: return "checkmark.circle.fill"
        case .returned: return "arrow.clockwise"
        }
    }
}

// MARK: - API Request/Response Models for Submissions
struct SubmissionRequest: Codable {
    let assignmentId: String
    let submissionText: String
    let fileIds: [String] // IDs of uploaded files
}

struct SubmissionResponse: Codable {
    let success: Bool
    let message: String
    let submission: AssignmentSubmission?
    let errors: [String]?
}

struct FileUploadResponse: Codable {
    let success: Bool
    let message: String
    let file: SubmissionFile?
    let uploadURL: String? // For direct upload to cloud storage
}

struct SubmissionHistoryResponse: Codable {
    let success: Bool
    let submissions: [AssignmentSubmission]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

// MARK: - Academic Goals Model
struct AcademicGoal: Codable, Identifiable {
    let id: String
    let type: GoalType // Changed from goalType to type
    let title: String
    let description: String
    let targetDate: Date
    let priority: Priority
    let status: GoalStatus
    let progress: Double // 0.0 to 1.0
    let createdDate: Date // Changed from createdAt to createdDate
    let updatedDate: Date // Changed from updatedAt to updatedDate
    
    // Computed property for backward compatibility
    var goalType: GoalType { type }
    var createdAt: Date { createdDate }
    var updatedAt: Date { updatedDate }
    
    enum GoalType: String, Codable, CaseIterable {
        case academic = "academic"
        case career = "career"
        case skill = "skill"
        case personal = "personal"
        
        var displayName: String {
            switch self {
            case .academic: return "Academic"
            case .career: return "Career"
            case .skill: return "Skill Development"
            case .personal: return "Personal"
            }
        }
        
        var icon: String {
            switch self {
            case .academic: return "graduationcap.fill"
            case .career: return "briefcase.fill"
            case .skill: return "star.fill"
            case .personal: return "person.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .academic: return .blue
            case .career: return .green
            case .skill: return .orange
            case .personal: return .purple
            }
        }
    }
    
    enum Priority: String, Codable, CaseIterable {
        case high = "high"
        case medium = "medium"
        case low = "low"
        
        var displayName: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
    }
    
    enum GoalStatus: String, Codable, CaseIterable {
        case active = "active"
        case completed = "completed"
        case paused = "paused"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .active: return "Active"
            case .completed: return "Completed"
            case .paused: return "Paused"
            case .cancelled: return "Cancelled"
            }
        }
        
        var color: Color {
            switch self {
            case .active: return .blue
            case .completed: return .green
            case .paused: return .orange
            case .cancelled: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .active: return "play.circle.fill"
            case .completed: return "checkmark.circle.fill"
            case .paused: return "pause.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Skills Model
struct Skill: Codable, Identifiable {
    let id: String
    let skillName: String
    let category: SkillCategory
    let proficiencyLevel: ProficiencyLevel
    let certifications: [String]?
    let lastUpdated: Date
    let endorsements: Int
    let isVerified: Bool
    
    enum SkillCategory: String, Codable, CaseIterable {
        case technical = "technical"
        case soft = "soft"
        case language = "language"
        case creative = "creative"
        case analytical = "analytical"
        
        var displayName: String {
            switch self {
            case .technical: return "Technical"
            case .soft: return "Soft Skills"
            case .language: return "Language"
            case .creative: return "Creative"
            case .analytical: return "Analytical"
            }
        }
        
        var icon: String {
            switch self {
            case .technical: return "laptopcomputer"
            case .soft: return "person.2.fill"
            case .language: return "globe"
            case .creative: return "paintbrush.fill"
            case .analytical: return "chart.bar.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .technical: return .blue
            case .soft: return .green
            case .language: return .orange
            case .creative: return .purple
            case .analytical: return .red
            }
        }
    }
    
    enum ProficiencyLevel: String, Codable, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        case expert = "expert"
        
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            case .expert: return "Expert"
            }
        }
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .blue
            case .advanced: return .orange
            case .expert: return .red
            }
        }
        
        var progressValue: Double {
            switch self {
            case .beginner: return 0.25
            case .intermediate: return 0.5
            case .advanced: return 0.75
            case .expert: return 1.0
            }
        }
    }
}

// MARK: - Registration Status
enum RegistrationStatus: String, Codable, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case graduated = "graduated"
    case suspended = "suspended"
    case transferred = "transferred"
    case dropout = "dropout"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .graduated: return "Graduated"
        case .suspended: return "Suspended"
        case .transferred: return "Transferred"
        case .dropout: return "Dropout"
        }
    }
    
    var color: Color {
        switch self {
        case .active: return .green
        case .inactive: return .gray
        case .graduated: return .blue
        case .suspended: return .red
        case .transferred: return .orange
        case .dropout: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .inactive: return "pause.circle.fill"
        case .graduated: return "graduationcap.fill"
        case .suspended: return "exclamationmark.triangle.fill"
        case .transferred: return "arrow.right.circle.fill"
        case .dropout: return "xmark.circle.fill"
        }
    }
} 