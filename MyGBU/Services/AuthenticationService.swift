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
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "" // TODO: Replace with actual API URL when backend is ready
    
    // MARK: - Login Methods
    func login(enrollmentNumber: String, password: String, userType: UserType) {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequest(
            enrollmentNumber: userType == .student ? enrollmentNumber : nil,
            employeeId: userType != .student ? enrollmentNumber : nil,
            password: password,
            userType: userType
        )
        
        performAPILogin(request: loginRequest)
    }
    
    // MARK: - Real API Login (Implement when backend is ready)
    private func performAPILogin(request: LoginRequest) {
        // TODO: Replace with actual API call when backend is ready
        // For now, simulate login with mock data
        simulateLogin(request: request)
    }
    
    // MARK: - Simulate Login (Remove when API is ready)
    private func simulateLogin(request: LoginRequest) {
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
                
            } else {
                // Invalid credentials
                self.errorMessage = "Invalid enrollment number or password"
                self.isLoading = false
            }
        }
    }
    
    private func createYadurajStudent(user: User) -> Student {
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
            academicInfo: AcademicInfo(cgpa: 8.7, totalCredits: 180, completedCredits: 120, backlogs: 0, attendance: 88.5)
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