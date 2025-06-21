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
    let course: String
    let branch: String
    let semester: Int
    let year: Int
    let section: String?
    let rollNumber: String
    let admissionDate: Date
    let dateOfBirth: Date
    let phoneNumber: String
    let address: Address
    let guardianInfo: GuardianInfo
    let academicInfo: AcademicInfo
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
    let enrollmentNumber: String?
    let employeeId: String?
    let password: String
    let userType: UserType
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let user: User?
    let student: Student?
    let faculty: Faculty?
    let admin: Admin?
    let expiresAt: Date?
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
    case resubmitted = "resubmitted"
    
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .submitted: return "Submitted"
        case .underReview: return "Under Review"
        case .graded: return "Graded"
        case .returned: return "Returned"
        case .resubmitted: return "Resubmitted"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return .gray
        case .submitted: return .orange
        case .underReview: return .blue
        case .graded: return .green
        case .returned: return .red
        case .resubmitted: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .draft: return "doc.text"
        case .submitted: return "paperplane.fill"
        case .underReview: return "eye.fill"
        case .graded: return "checkmark.circle.fill"
        case .returned: return "arrow.uturn.left.circle.fill"
        case .resubmitted: return "arrow.clockwise.circle.fill"
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