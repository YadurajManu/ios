import Foundation
import Combine

// MARK: - Student API Service
class StudentAPIService: ObservableObject {
    static let shared = StudentAPIService()
    
    // MARK: - API Configuration
    private let baseURL = "http://localhost:8002/api" // Academic Management Service
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {}
    
    // MARK: - Student Profile API
    
    /// Fetch student profile by ID
    func fetchStudentProfile(studentId: String) async throws -> Student {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(studentId)")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let student = try JSONDecoder().decode(Student.self, from: data)
            return student
            
        } catch {
            // Fallback to mock data for development
            print("⚠️ API call failed, using mock data: \(error)")
            return createMockStudent(studentId: studentId)
        }
    }
    
    /// Update student profile
    func updateStudentProfile(_ student: Student) async throws -> Student {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(student.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = StudentUpdateRequest(
            batch: student.batch,
            registrationStatus: student.registrationStatus.rawValue,
            academicGoals: student.academicGoals,
            skillsStrengths: student.skillsStrengths
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let updatedStudent = try JSONDecoder().decode(Student.self, from: data)
            return updatedStudent
            
        } catch {
            print("⚠️ Update failed, returning original student: \(error)")
            return student
        }
    }
    
    // MARK: - Academic Goals API
    
    /// Fetch academic goals for student
    func fetchAcademicGoals(studentId: String) async throws -> [AcademicGoal] {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(studentId)/academic-goals")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let goals = try JSONDecoder().decode([AcademicGoal].self, from: data)
            return goals
            
        } catch {
            print("⚠️ API call failed, using mock goals: \(error)")
            return createMockAcademicGoals()
        }
    }
    
    /// Create new academic goal
    func createAcademicGoal(studentId: String, goal: AcademicGoal) async throws -> AcademicGoal {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(studentId)/academic-goals")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(goal)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                throw APIError.invalidResponse
            }
            
            let createdGoal = try JSONDecoder().decode(AcademicGoal.self, from: data)
            return createdGoal
            
        } catch {
            print("⚠️ Create goal failed, returning original: \(error)")
            return goal
        }
    }
    
    /// Update academic goal progress
    func updateGoalProgress(goalId: String, progress: Double) async throws -> AcademicGoal {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/academic-goals/\(goalId)/progress")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateRequest = GoalProgressUpdate(progress: progress, updatedAt: Date())
        
        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let updatedGoal = try JSONDecoder().decode(AcademicGoal.self, from: data)
            return updatedGoal
            
        } catch {
            print("⚠️ Update progress failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Skills API
    
    /// Fetch skills for student
    func fetchSkills(studentId: String) async throws -> [Skill] {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(studentId)/skills")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let skills = try JSONDecoder().decode([Skill].self, from: data)
            return skills
            
        } catch {
            print("⚠️ API call failed, using mock skills: \(error)")
            return createMockSkills()
        }
    }
    
    /// Add new skill
    func addSkill(studentId: String, skill: Skill) async throws -> Skill {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/students/\(studentId)/skills")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(skill)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                throw APIError.invalidResponse
            }
            
            let createdSkill = try JSONDecoder().decode(Skill.self, from: data)
            return createdSkill
            
        } catch {
            print("⚠️ Add skill failed, returning original: \(error)")
            return skill
        }
    }
    
    /// Update skill proficiency
    func updateSkillProficiency(skillId: String, proficiency: Skill.ProficiencyLevel) async throws -> Skill {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(baseURL)/skills/\(skillId)/proficiency")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateRequest = SkillProficiencyUpdate(
            proficiencyLevel: proficiency.rawValue,
            lastUpdated: Date()
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let updatedSkill = try JSONDecoder().decode(Skill.self, from: data)
            return updatedSkill
            
        } catch {
            print("⚠️ Update skill failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Batch Operations
    
    /// Sync all student data
    func syncStudentData(studentId: String) async throws -> StudentDataResponse {
        isLoading = true
        defer { isLoading = false }
        
        async let studentProfile = fetchStudentProfile(studentId: studentId)
        async let academicGoals = fetchAcademicGoals(studentId: studentId)
        async let skills = fetchSkills(studentId: studentId)
        
        do {
            let (profile, goals, skillsList) = try await (studentProfile, academicGoals, skills)
            
            return StudentDataResponse(
                student: profile,
                academicGoals: goals,
                skills: skillsList,
                lastSyncAt: Date()
            )
        } catch {
            print("⚠️ Sync failed, using mock data: \(error)")
            return createMockStudentDataResponse(studentId: studentId)
        }
    }
}

// MARK: - Request/Response Models

struct StudentUpdateRequest: Codable {
    let batch: String
    let registrationStatus: String
    let academicGoals: [AcademicGoal]?
    let skillsStrengths: [Skill]?
}

struct GoalProgressUpdate: Codable {
    let progress: Double
    let updatedAt: Date
}

struct SkillProficiencyUpdate: Codable {
    let proficiencyLevel: String
    let lastUpdated: Date
}

struct StudentDataResponse: Codable {
    let student: Student
    let academicGoals: [AcademicGoal]
    let skills: [Skill]
    let lastSyncAt: Date
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Data (Remove when API is ready)

extension StudentAPIService {
    private func createMockStudent(studentId: String) -> Student {
        let user = User(
            id: studentId,
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
            id: studentId,
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
            batch: "2022-2026",
            registrationStatus: RegistrationStatus.active,
            academicGoals: createMockAcademicGoals(),
            skillsStrengths: createMockSkills(),
            createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            updatedAt: Date()
        )
    }
    
    private func createMockAcademicGoals() -> [AcademicGoal] {
        return [
            AcademicGoal(
                id: UUID().uuidString,
                type: AcademicGoal.GoalType.academic,
                title: "Achieve 9.0+ CGPA",
                description: "Maintain excellent academic performance throughout the semester",
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
                priority: AcademicGoal.Priority.high,
                status: AcademicGoal.GoalStatus.active,
                progress: 0.75,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 15))!,
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: AcademicGoal.GoalType.career,
                title: "Secure Software Engineer Role",
                description: "Get placed in a top-tier tech company with competitive package",
                targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date())!,
                priority: AcademicGoal.Priority.high,
                status: AcademicGoal.GoalStatus.active,
                progress: 0.45,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 1))!,
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: AcademicGoal.GoalType.skill,
                title: "Complete Advanced Data Structures",
                description: "Master advanced algorithms and data structures for competitive programming",
                targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                priority: AcademicGoal.Priority.medium,
                status: AcademicGoal.GoalStatus.active,
                progress: 0.80,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 10))!,
                updatedDate: Date()
            )
        ]
    }
    
    private func createMockSkills() -> [Skill] {
        return [
            Skill(
                id: UUID().uuidString,
                skillName: "Swift Programming",
                category: Skill.SkillCategory.technical,
                proficiencyLevel: Skill.ProficiencyLevel.advanced,
                certifications: ["iOS Development Certification", "Swift Associate Certification"],
                lastUpdated: Date(),
                endorsements: 15,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Problem Solving",
                category: Skill.SkillCategory.analytical,
                proficiencyLevel: Skill.ProficiencyLevel.expert,
                certifications: nil,
                lastUpdated: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                endorsements: 22,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Database Management",
                category: Skill.SkillCategory.technical,
                proficiencyLevel: Skill.ProficiencyLevel.intermediate,
                certifications: ["MySQL Fundamentals", "PostgreSQL Basics"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                endorsements: 8,
                isVerified: true
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Leadership",
                category: Skill.SkillCategory.soft,
                proficiencyLevel: Skill.ProficiencyLevel.advanced,
                certifications: ["Leadership Excellence Program"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                endorsements: 12,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "UI/UX Design",
                category: Skill.SkillCategory.creative,
                proficiencyLevel: Skill.ProficiencyLevel.intermediate,
                certifications: ["Google UX Design Certificate"],
                lastUpdated: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                endorsements: 6,
                isVerified: true
            )
        ]
    }
    
    private func createMockStudentDataResponse(studentId: String) -> StudentDataResponse {
        return StudentDataResponse(
            student: createMockStudent(studentId: studentId),
            academicGoals: createMockAcademicGoals(),
            skills: createMockSkills(),
            lastSyncAt: Date()
        )
    }
} 