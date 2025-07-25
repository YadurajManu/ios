import Foundation
import SwiftUI

// MARK: - Course Registration & Enrollment Models (Based on ERP Data Structure)

// MARK: - Student Program Enrollment
struct StudentProgramEnrollment: Codable, Identifiable {
    let id: String // enrollment_id from ERP
    let studentId: String
    let programId: String
    let batchYear: String
    let enrollmentStatus: EnrollmentStatus
    let enrollmentDate: Date
    let expectedGraduation: Date
    let admissionDetails: [String: String]
    let createdAt: Date
    let updatedAt: Date
    
    enum EnrollmentStatus: String, Codable, CaseIterable {
        case enrolled = "enrolled"
        case active = "active"
        case inactive = "inactive"
        case suspended = "suspended"
        case graduated = "graduated"
        case withdrawn = "withdrawn"
        
        var displayName: String {
            switch self {
            case .enrolled: return "Enrolled"
            case .active: return "Active"
            case .inactive: return "Inactive"
            case .suspended: return "Suspended"
            case .graduated: return "Graduated"
            case .withdrawn: return "Withdrawn"
            }
        }
        
        var color: Color {
            switch self {
            case .enrolled, .active: return .green
            case .inactive: return .gray
            case .suspended: return .orange
            case .graduated: return .blue
            case .withdrawn: return .red
            }
        }
    }
}

// MARK: - Semester Registration
struct SemesterRegistration: Codable, Identifiable {
    let id: String // registration_id from ERP
    let studentId: String
    let semesterId: String
    let academicYear: String
    let registrationType: RegistrationType
    let status: SemesterRegistrationStatus
    let totalCredits: Double
    let registrationDate: Date
    let lastDate: Date
    let feeDetails: FeeDetails?
    let createdAt: Date
    let updatedAt: Date
    
    enum RegistrationType: String, Codable, CaseIterable {
        case regular = "regular"
        case supplementary = "supplementary"
        case improvement = "improvement"
        case reappear = "reappear"
        
        var displayName: String {
            switch self {
            case .regular: return "Regular"
            case .supplementary: return "Supplementary"
            case .improvement: return "Improvement"
            case .reappear: return "Re-appear"
            }
        }
    }
    
    enum SemesterRegistrationStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case inProgress = "in_progress"
        case completed = "completed"
        case approved = "approved"
        case rejected = "rejected"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            case .cancelled: return "Cancelled"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .inProgress: return .blue
            case .completed: return .green
            case .approved: return .green
            case .rejected: return .red
            case .cancelled: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .pending: return "clock.fill"
            case .inProgress: return "arrow.clockwise"
            case .completed: return "checkmark.circle.fill"
            case .approved: return "checkmark.seal.fill"
            case .rejected: return "xmark.circle.fill"
            case .cancelled: return "minus.circle.fill"
            }
        }
    }
}

// MARK: - Course Registration
struct CourseRegistration: Codable, Identifiable {
    let id: String // course_reg_id from ERP
    let studentId: String
    let courseId: String
    let semesterRegistrationId: String
    let registrationType: CourseRegistrationType
    let status: CourseRegistrationStatus
    let registrationDate: Date
    let priority: Int? // For elective selection priority
    let additionalInfo: [String: String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CourseRegistrationType: String, Codable, CaseIterable {
        case regular = "regular"
        case audit = "audit"
        case credit = "credit"
        case improvement = "improvement"
        
        var displayName: String {
            switch self {
            case .regular: return "Regular"
            case .audit: return "Audit"
            case .credit: return "Credit"
            case .improvement: return "Improvement"
            }
        }
    }
    
    enum CourseRegistrationStatus: String, Codable, CaseIterable {
        case selected = "selected"
        case waitlisted = "waitlisted"
        case confirmed = "confirmed"
        case dropped = "dropped"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .selected: return "Selected"
            case .waitlisted: return "Waitlisted"
            case .confirmed: return "Confirmed"
            case .dropped: return "Dropped"
            case .completed: return "Completed"
            }
        }
        
        var color: Color {
            switch self {
            case .selected: return .blue
            case .waitlisted: return .orange
            case .confirmed: return .green
            case .dropped: return .red
            case .completed: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .selected: return "hand.point.up.left.fill"
            case .waitlisted: return "clock.badge.fill"
            case .confirmed: return "checkmark.circle.fill"
            case .dropped: return "minus.circle.fill"
            case .completed: return "graduationcap.fill"
            }
        }
    }
}

// MARK: - Fee Details
struct FeeDetails: Codable {
    let totalAmount: Double
    let paidAmount: Double
    let pendingAmount: Double
    let dueDate: Date
    let feeComponents: [FeeComponent]
    
    var isPaid: Bool {
        pendingAmount <= 0
    }
    
    var paymentStatus: PaymentStatus {
        if isPaid {
            return .paid
        } else if Date() > dueDate {
            return .overdue
        } else {
            return .pending
        }
    }
    
    enum PaymentStatus: String, Codable {
        case paid = "paid"
        case pending = "pending"
        case overdue = "overdue"
        case partial = "partial"
        
        var displayName: String {
            switch self {
            case .paid: return "Paid"
            case .pending: return "Pending"
            case .overdue: return "Overdue"
            case .partial: return "Partial"
            }
        }
        
        var color: Color {
            switch self {
            case .paid: return .green
            case .pending: return .orange
            case .overdue: return .red
            case .partial: return .blue
            }
        }
    }
}

// MARK: - Fee Component
struct FeeComponent: Codable, Identifiable {
    let id: String
    let name: String
    let amount: Double
    let isOptional: Bool
    
    var displayName: String {
        isOptional ? "\(name) (Optional)" : name
    }
}

// MARK: - Registration Period
struct RegistrationPeriod: Codable, Identifiable {
    let id: String
    let semesterId: String
    let academicYear: String
    let startDate: Date
    let endDate: Date
    let lateRegistrationEndDate: Date?
    let isActive: Bool
    let registrationTypes: [SemesterRegistration.RegistrationType]
    
    var isCurrentlyOpen: Bool {
        let now = Date()
        return isActive && now >= startDate && now <= endDate
    }
    
    var isLateRegistrationOpen: Bool {
        guard let lateEndDate = lateRegistrationEndDate else { return false }
        let now = Date()
        return isActive && now > endDate && now <= lateEndDate
    }
    
    var status: RegistrationPeriodStatus {
        let now = Date()
        if now < startDate {
            return .upcoming
        } else if isCurrentlyOpen {
            return .open
        } else if isLateRegistrationOpen {
            return .lateRegistration
        } else {
            return .closed
        }
    }
    
    enum RegistrationPeriodStatus: String, Codable {
        case upcoming = "upcoming"
        case open = "open"
        case lateRegistration = "late_registration"
        case closed = "closed"
        
        var displayName: String {
            switch self {
            case .upcoming: return "Upcoming"
            case .open: return "Open"
            case .lateRegistration: return "Late Registration"
            case .closed: return "Closed"
            }
        }
        
        var color: Color {
            switch self {
            case .upcoming: return .blue
            case .open: return .green
            case .lateRegistration: return .orange
            case .closed: return .red
            }
        }
    }
}

// MARK: - Registration Summary
struct RegistrationSummary: Codable {
    let studentId: String
    let semesterRegistrationId: String
    let selectedCourses: [CourseRegistration]
    let totalCredits: Double
    let minCreditsRequired: Int
    let maxCreditsAllowed: Int
    let coreCoursesCount: Int
    let electiveCoursesCount: Int
    let practicalCoursesCount: Int
    let isValid: Bool
    let validationErrors: [RegistrationValidationError]
    
    var creditStatus: CreditStatus {
        if totalCredits < Double(minCreditsRequired) {
            return .belowMinimum
        } else if totalCredits > Double(maxCreditsAllowed) {
            return .aboveMaximum
        } else {
            return .valid
        }
    }
    
    enum CreditStatus {
        case belowMinimum
        case valid
        case aboveMaximum
        
        var displayName: String {
            switch self {
            case .belowMinimum: return "Below Minimum Credits"
            case .valid: return "Valid Credits"
            case .aboveMaximum: return "Above Maximum Credits"
            }
        }
        
        var color: Color {
            switch self {
            case .belowMinimum: return .red
            case .valid: return .green
            case .aboveMaximum: return .orange
            }
        }
    }
}

// MARK: - Registration Validation Error
struct RegistrationValidationError: Codable, Identifiable {
    let id: String
    let courseId: String?
    let errorType: ValidationErrorType
    let message: String
    let severity: Severity
    
    enum ValidationErrorType: String, Codable {
        case prerequisiteNotMet = "prerequisite_not_met"
        case scheduleConflict = "schedule_conflict"
        case creditLimitExceeded = "credit_limit_exceeded"
        case courseFull = "course_full"
        case electiveLimitExceeded = "elective_limit_exceeded"
        case coreCourseMissing = "core_course_missing"
        
        var displayName: String {
            switch self {
            case .prerequisiteNotMet: return "Prerequisite Not Met"
            case .scheduleConflict: return "Schedule Conflict"
            case .creditLimitExceeded: return "Credit Limit Exceeded"
            case .courseFull: return "Course Full"
            case .electiveLimitExceeded: return "Elective Limit Exceeded"
            case .coreCourseMissing: return "Core Course Missing"
            }
        }
    }
    
    enum Severity: String, Codable {
        case error = "error"
        case warning = "warning"
        case info = "info"
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "exclamationmark.triangle.fill"
            case .warning: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
}

// MARK: - Registration Request/Response Models for API

struct SemesterRegistrationRequest: Codable {
    let studentId: String
    let semesterId: String
    let academicYear: String
    let registrationType: SemesterRegistration.RegistrationType
    let selectedCourses: [CourseSelectionRequest]
}

struct CourseSelectionRequest: Codable {
    let courseId: String
    let registrationType: CourseRegistration.CourseRegistrationType
    let priority: Int?
}

struct RegistrationResponse: Codable {
    let success: Bool
    let message: String
    let registrationId: String?
    let validationErrors: [RegistrationValidationError]?
}

struct RegistrationStatusResponse: Codable {
    let semesterRegistration: SemesterRegistration
    let courseRegistrations: [CourseRegistration]
    let registrationSummary: RegistrationSummary
}

// MARK: - Registration Analytics
struct RegistrationAnalytics: Codable {
    let totalStudentsEligible: Int
    let studentsRegistered: Int
    let pendingRegistrations: Int
    let courseWiseRegistration: [CourseRegistrationStats]
    let registrationTrends: [RegistrationTrend]
    
    var registrationPercentage: Double {
        guard totalStudentsEligible > 0 else { return 0 }
        return (Double(studentsRegistered) / Double(totalStudentsEligible)) * 100
    }
}

struct CourseRegistrationStats: Codable, Identifiable {
    let id: String
    let courseId: String
    let courseName: String
    let capacity: Int
    let registered: Int
    let waitlisted: Int
    
    var fillPercentage: Double {
        guard capacity > 0 else { return 0 }
        return (Double(registered) / Double(capacity)) * 100
    }
    
    var isOversubscribed: Bool {
        registered > capacity
    }
}

struct RegistrationTrend: Codable, Identifiable {
    let id: String
    let date: Date
    let registrationsCount: Int
    let cumulativeCount: Int
} 