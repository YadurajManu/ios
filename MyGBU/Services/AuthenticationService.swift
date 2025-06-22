import Foundation
import Combine

// MARK: - Authentication Service
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentStudent: Student?
    @Published var currentFaculty: Faculty?
    @Published var currentAdmin: Admin?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var rememberMe = false
    @Published var savedCredentials: SavedCredentials?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "" // TODO: Replace with actual API URL when backend is ready
    
    init() {
        loadSavedCredentials()
    }
    
    // MARK: - Login Methods
    func login(enrollmentNumber: String, password: String, userType: UserType, rememberMe: Bool = false) {
        isLoading = true
        errorMessage = nil
        self.rememberMe = rememberMe
        
        let loginRequest = LoginRequest(
            enrollmentNumber: userType == .student ? enrollmentNumber : nil,
            employeeId: userType != .student ? enrollmentNumber : nil,
            password: password,
            userType: userType
        )
        
        performAPILogin(request: loginRequest, credentials: (enrollmentNumber, password, userType))
    }
    
    // MARK: - Real API Login (Implement when backend is ready)
    private func performAPILogin(request: LoginRequest, credentials: (String, String, UserType)) {
        // TODO: Replace with actual API call when backend is ready
        // For now, simulate login with mock data
        simulateLogin(request: request, credentials: credentials)
    }
    
    // MARK: - Simulate Login (Remove when API is ready)
    private func simulateLogin(request: LoginRequest, credentials: (String, String, UserType)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Check for specific demo account credentials
            if request.userType == .student && 
               request.enrollmentNumber == "245uai130" && 
               request.password == "Yadu@1234" {
                
                // Create Yaduraj Singh's account
                let mockUser = User(
                    id: "STU245UAI130",
                    userType: request.userType,
                    email: "yaduraj.singh@gbu.ac.in",
                    firstName: "Yaduraj",
                    lastName: "Singh",
                    profileImageURL: nil,
                    isActive: true,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                self.currentUser = mockUser
                self.currentStudent = self.createYadurajStudent(user: mockUser)
                self.isAuthenticated = true
                self.isLoading = false
                self.saveAuthToken("demo_token_yaduraj_\(UUID().uuidString)")
                
                // Save credentials if Remember Me is enabled
                if self.rememberMe {
                    self.saveCredentials(
                        enrollmentNumber: credentials.0,
                        password: credentials.1,
                        userType: credentials.2
                    )
                } else {
                    self.clearSavedCredentials()
                }
                
            } else {
                // Invalid credentials
                self.errorMessage = "Invalid enrollment number or password"
                self.isLoading = false
            }
        }
    }
    
    private func createYadurajStudent(user: User) -> Student {
        // Mock Academic Goals
        let academicGoals = [
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
                title: "Master Advanced iOS Development",
                description: "Complete advanced iOS development projects and certifications",
                targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())!,
                priority: AcademicGoal.Priority.medium,
                status: AcademicGoal.GoalStatus.active,
                progress: 0.60,
                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 10))!,
                updatedDate: Date()
            )
        ]
        
        // Mock Skills & Strengths
        let skillsStrengths = [
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
        
        return Student(
            id: user.id,
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
            address: Address(street: "123 University Road", city: "Greater Noida", state: "UP", pincode: "201310", country: "India"),
            guardianInfo: GuardianInfo(name: "Sujeet Kumar Singh", relationship: "Father", phoneNumber: "+91 9876543211", email: "sujeet.singh@email.com", occupation: "Professional"),
            academicInfo: AcademicInfo(cgpa: 8.7, totalCredits: 180, completedCredits: 120, backlogs: 0, attendance: 88.5),
            
            // NEW FIELDS
            batch: "2022-2026",
            registrationStatus: RegistrationStatus.active,
            academicGoals: academicGoals,
            skillsStrengths: skillsStrengths,
            createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            updatedAt: Date()
        )
    }
    
    // MARK: - Remember Me Functionality
    func saveCredentials(enrollmentNumber: String, password: String, userType: UserType) {
        let credentials = SavedCredentials(
            enrollmentNumber: enrollmentNumber,
            password: password,
            userType: userType,
            savedAt: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(credentials) {
            KeychainHelper.save(String(data: encoded, encoding: .utf8) ?? "", for: "saved_credentials")
            self.savedCredentials = credentials
        }
    }
    
    func loadSavedCredentials() {
        if let credentialsString = KeychainHelper.get(for: "saved_credentials"),
           let credentialsData = credentialsString.data(using: .utf8),
           let credentials = try? JSONDecoder().decode(SavedCredentials.self, from: credentialsData) {
            
            // Check if credentials are not older than 30 days
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            if credentials.savedAt > thirtyDaysAgo {
                self.savedCredentials = credentials
                self.rememberMe = true
            } else {
                // Clear expired credentials
                clearSavedCredentials()
            }
        }
    }
    
    func clearSavedCredentials() {
        KeychainHelper.delete(for: "saved_credentials")
        self.savedCredentials = nil
        self.rememberMe = false
    }
    
    func autoLogin() {
        guard let credentials = savedCredentials else { return }
        
        login(
            enrollmentNumber: credentials.enrollmentNumber,
            password: credentials.password,
            userType: credentials.userType,
            rememberMe: true
        )
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        currentStudent = nil
        currentFaculty = nil
        currentAdmin = nil
        isAuthenticated = false
        errorMessage = nil
        removeAuthToken()
        
        // Don't clear saved credentials on logout if Remember Me is enabled
        if !rememberMe {
            clearSavedCredentials()
        }
    }
    
    // MARK: - Token Management
    private func saveAuthToken(_ token: String) {
        KeychainHelper.save(token, for: "auth_token")
    }
    
    private func getAuthToken() -> String? {
        return KeychainHelper.get(for: "auth_token")
    }
    
    private func removeAuthToken() {
        KeychainHelper.delete(for: "auth_token")
    }
    
    // MARK: - Check Authentication Status
    func checkAuthenticationStatus() {
        if getAuthToken() != nil {
            // TODO: Validate token with backend when ready
            // validateTokenWithBackend(token)
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(enrollmentNumber: String, userType: UserType) {
        // TODO: Implement password reset functionality
        print("Password reset requested for: \(enrollmentNumber)")
    }
}

// MARK: - Saved Credentials Model
struct SavedCredentials: Codable {
    let enrollmentNumber: String
    let password: String
    let userType: UserType
    let savedAt: Date
}

// MARK: - Keychain Helper
class KeychainHelper {
    static func save(_ data: String, for key: String) {
        let data = data.data(using: .utf8)!
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func get(for key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    
    static func delete(for key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
} 