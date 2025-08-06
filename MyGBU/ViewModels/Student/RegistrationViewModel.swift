import Foundation
import Combine
import SwiftUI

class RegistrationViewModel: ObservableObject {
    @Published var registrationService = RegistrationService()
    
    // MARK: - Registration Flow State
    @Published var currentStep: RegistrationStep = .schoolSelection
    @Published var formData = RegistrationFormData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Available Options
    @Published var availableSchools: [School] = []
    @Published var availableCourses: [Course] = []
    @Published var studentRegistrations: [SemesterRegistration] = []
    
    // MARK: - Validation State
    @Published var validationErrors: [String] = []
    @Published var isFormValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    enum RegistrationStep: Int, CaseIterable {
        case schoolSelection = 0
        case courseSelection = 1
        case formCompletion = 2
        case review = 3
        case confirmation = 4
        
        var title: String {
            switch self {
            case .schoolSelection: return "Select School"
            case .courseSelection: return "Select Courses"
            case .formCompletion: return "Complete Form"
            case .review: return "Review"
            case .confirmation: return "Confirmation"
            }
        }
        
        var icon: String {
            switch self {
            case .schoolSelection: return "building.2"
            case .courseSelection: return "book"
            case .formCompletion: return "doc.text"
            case .review: return "checkmark.circle"
            case .confirmation: return "checkmark.seal"
            }
        }
    }
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Monitor form data changes for validation
        $formData
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] formData in
                self?.validateForm()
            }
            .store(in: &cancellables)
        
        // Monitor registration service state
        registrationService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        registrationService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        registrationService.$schools
            .assign(to: \.availableSchools, on: self)
            .store(in: &cancellables)
        
        registrationService.$courses
            .assign(to: \.availableCourses, on: self)
            .store(in: &cancellables)
        
        registrationService.$studentRegistrations
            .assign(to: \.studentRegistrations, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadInitialData() {
        registrationService.fetchSchools()
    }
    
    func loadCourses(for school: School) {
        registrationService.fetchCourses(for: school)
    }
    
    func loadStudentRegistrations(studentId: Int) {
        registrationService.fetchStudentRegistrations(studentId: studentId)
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard currentStep.rawValue < RegistrationStep.allCases.count - 1 else { return }
        currentStep = RegistrationStep(rawValue: currentStep.rawValue + 1) ?? .schoolSelection
    }
    
    func previousStep() {
        guard currentStep.rawValue > 0 else { return }
        currentStep = RegistrationStep(rawValue: currentStep.rawValue - 1) ?? .schoolSelection
    }
    
    func goToStep(_ step: RegistrationStep) {
        currentStep = step
    }
    
    // MARK: - Form Actions
    func selectSchool(_ school: School) {
        formData.selectedSchool = school
        loadCourses(for: school)
        nextStep()
    }
    
    func toggleCourseSelection(_ course: Course) {
        if let index = formData.selectedCourses.firstIndex(where: { $0.id == course.id }) {
            formData.selectedCourses.remove(at: index)
        } else {
            formData.selectedCourses.append(course)
        }
        updateTotalCredits()
    }
    
    func updateTotalCredits() {
        formData.totalCredits = formData.selectedCourses.reduce(0) { $0 + Double($1.totalCredits) }
    }
    
    // MARK: - Validation
    private func validateForm() {
        validationErrors.removeAll()
        
        // School validation
        if formData.selectedSchool == nil {
            validationErrors.append("Please select a school")
        }
        
        // Course validation
        if formData.selectedCourses.isEmpty {
            validationErrors.append("Please select at least one course")
        }
        
        // Credit validation
        if formData.totalCredits < 12 {
            validationErrors.append("Minimum 12 credits required")
        }
        
        if formData.totalCredits > 24 {
            validationErrors.append("Maximum 24 credits allowed")
        }
        
        // Academic year validation
        if formData.academicYear.isEmpty {
            validationErrors.append("Please enter academic year")
        }
        
        // Check for course conflicts
        let courseCodes = formData.selectedCourses.map { $0.courseCode }
        let uniqueCodes = Set(courseCodes)
        if courseCodes.count != uniqueCodes.count {
            validationErrors.append("Duplicate courses selected")
        }
        
        // Check prerequisites
        for course in formData.selectedCourses {
            if !course.prerequisites.isEmpty {
                let selectedCodes = Set(formData.selectedCourses.map { $0.courseCode })
                let missingPrerequisites = course.prerequisites.filter { !selectedCodes.contains($0) }
                if !missingPrerequisites.isEmpty {
                    validationErrors.append("Missing prerequisites for \(course.courseName): \(missingPrerequisites.joined(separator: ", "))")
                }
            }
        }
        
        isFormValid = validationErrors.isEmpty && formData.isValid
    }
    
    // MARK: - Submission
    func submitRegistration(studentId: Int) {
        guard isFormValid else {
            errorMessage = "Please fix validation errors before submitting"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Create semester registration request
        let semesterRequest = SemesterRegistrationRequest(
            studentId: studentId,
            semesterId: 1, // This should come from the current semester
            academicYear: formData.academicYear,
            registrationType: formData.registrationType.rawValue,
            totalCredits: formData.totalCredits,
            feeDetails: formData.feeDetails
        )
        
        // Submit semester registration
        registrationService.submitSemesterRegistration(semesterRequest)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Registration failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] semesterRegistration in
                    self?.submitCourseRegistrations(
                        studentId: studentId,
                        semesterRegistrationId: semesterRegistration.id
                    )
                }
            )
            .store(in: &cancellables)
    }
    
    private func submitCourseRegistrations(studentId: Int, semesterRegistrationId: Int) {
        let courseRequests = formData.selectedCourses.map { course in
            CourseRegistrationRequest(
                studentId: studentId,
                courseId: Int(course.id) ?? 0,
                semesterRegistrationId: semesterRegistrationId,
                registrationType: "regular",
                additionalInfo: ["notes": formData.additionalNotes]
            )
        }
        
        // Submit all course registrations
        let publishers = courseRequests.map { request in
            registrationService.submitCourseRegistration(request)
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Course registration failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] courseRegistrations in
                    self?.successMessage = "Registration completed successfully! \(courseRegistrations.count) courses registered."
                    self?.nextStep()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Reset
    func resetForm() {
        formData = RegistrationFormData()
        currentStep = .schoolSelection
        validationErrors.removeAll()
        errorMessage = nil
        successMessage = nil
    }
    
    // MARK: - Helper Methods
    func getCoursesByType(_ type: String) -> [Course] {
        return availableCourses.filter { $0.courseType.rawValue == type }
    }
    
    func isCourseSelected(_ course: Course) -> Bool {
        return formData.selectedCourses.contains { $0.id == course.id }
    }
    
    func getCourseTypeDisplayName(_ type: String) -> String {
        switch type {
        case "core": return "Core Course"
        case "elective": return "Elective Course"
        case "practical": return "Practical"
        case "project": return "Project"
        case "internship": return "Internship"
        case "seminar": return "Seminar"
        default: return type.capitalized
        }
    }
    
    func getCourseTypeColor(_ type: String) -> Color {
        switch type {
        case "core": return .red
        case "elective": return .blue
        case "practical": return .green
        case "project": return .orange
        case "internship": return .purple
        case "seminar": return .gray
        default: return .gray
        }
    }
} 