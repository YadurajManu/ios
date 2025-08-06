import Foundation
import SwiftUI

// MARK: - Student Enrollment Models
struct StudentEnrollment: Codable, Identifiable {
    let id: Int // enrollment_id
    let studentId: Int
    let programId: Int
    let batchYear: String
    let enrollmentStatus: String
    let enrollmentDate: String
    let expectedGraduation: String?
    let admissionDetails: [String: String]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "enrollment_id"
        case studentId = "student_id"
        case programId = "program_id"
        case batchYear = "batch_year"
        case enrollmentStatus = "enrollment_status"
        case enrollmentDate = "enrollment_date"
        case expectedGraduation = "expected_graduation"
        case admissionDetails = "admission_details"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct StudentEnrollmentRequest: Codable {
    let studentId: Int
    let programId: Int
    let batchYear: String
    let enrollmentStatus: String
    let admissionDetails: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case programId = "program_id"
        case batchYear = "batch_year"
        case enrollmentStatus = "enrollment_status"
        case admissionDetails = "admission_details"
    }
}

// MARK: - Semester Registration Models
struct SemesterRegistration: Codable, Identifiable {
    let id: Int // registration_id
    let studentId: Int
    let semesterId: Int
    let academicYear: String
    let registrationType: String
    let status: String
    let totalCredits: Double
    let registrationDate: String
    let lastDate: String?
    let feeDetails: [String: String]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "registration_id"
        case studentId = "student_id"
        case semesterId = "semester_id"
        case academicYear = "academic_year"
        case registrationType = "registration_type"
        case status, totalCredits = "total_credits"
        case registrationDate = "registration_date"
        case lastDate = "last_date"
        case feeDetails = "fee_details"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SemesterRegistrationRequest: Codable {
    let studentId: Int
    let semesterId: Int
    let academicYear: String
    let registrationType: String
    let totalCredits: Double
    let feeDetails: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case semesterId = "semester_id"
        case academicYear = "academic_year"
        case registrationType = "registration_type"
        case totalCredits = "total_credits"
        case feeDetails = "fee_details"
    }
}

// MARK: - Course Registration Models
struct CourseRegistration: Codable, Identifiable {
    let id: Int // course_reg_id
    let studentId: Int
    let courseId: Int
    let semesterRegistrationId: Int
    let registrationType: String
    let status: String
    let registrationDate: String
    let additionalInfo: [String: String]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "course_reg_id"
        case studentId = "student_id"
        case courseId = "course_id"
        case semesterRegistrationId = "semester_registration_id"
        case registrationType = "registration_type"
        case status, registrationDate = "registration_date"
        case additionalInfo = "additional_info"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CourseRegistrationRequest: Codable {
    let studentId: Int
    let courseId: Int
    let semesterRegistrationId: Int
    let registrationType: String
    let additionalInfo: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case courseId = "course_id"
        case semesterRegistrationId = "semester_registration_id"
        case registrationType = "registration_type"
        case additionalInfo = "additional_info"
    }
}

// MARK: - Registration Form Models
struct RegistrationFormData: Codable {
    var selectedSchool: School?
    var selectedCourses: [Course] = []
    var registrationType: RegistrationType = .newSemester
    var academicYear: String = ""
    var totalCredits: Double = 0.0
    var additionalNotes: String = ""
    var feeDetails: [String: String] = [:]
    
    var isValid: Bool {
        return selectedSchool != nil && 
               !selectedCourses.isEmpty && 
               !academicYear.isEmpty &&
               totalCredits > 0
    }
}

enum RegistrationType: String, CaseIterable, Codable {
    case newSemester = "new_semester"
    case courseAddition = "course_addition"
    case courseWithdrawal = "course_withdrawal"
    case semesterWithdrawal = "semester_withdrawal"
    
    var displayName: String {
        switch self {
        case .newSemester: return "New Semester Registration"
        case .courseAddition: return "Course Addition"
        case .courseWithdrawal: return "Course Withdrawal"
        case .semesterWithdrawal: return "Semester Withdrawal"
        }
    }
} 