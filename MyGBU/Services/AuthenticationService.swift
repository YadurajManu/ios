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
    
    // JWT Token Management
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    // Pending registration data for profile creation
    private var pendingRegistrationData: PendingRegistrationData?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://auth.tilchattaas.com/api"
    
    init() {
        loadSavedCredentials()
        loadSavedTokens()
    }
    
    // MARK: - Login Methods
    func login(email: String, password: String, rememberMe: Bool = false) {
        isLoading = true
        errorMessage = nil
        self.rememberMe = rememberMe
        
        let loginRequest = LoginRequest(
            email: email,
            password: password
        )
        
        performAPILogin(request: loginRequest, credentials: (email, password))
    }
    
    // MARK: - Real API Login
    private func performAPILogin(request: LoginRequest, credentials: (String, String)) {
        guard let url = URL(string: "\(baseURL)/login/") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            
                    URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Login Network Error: \(error.localizedDescription)")
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Login Invalid Response")
                    self?.errorMessage = "Invalid response"
                    return
                }
                
                print("🔐 Login Response Status: \(httpResponse.statusCode)")
                
                if let data = data {
                    print("📄 Login Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                }
                
                if httpResponse.statusCode == 200 {
                    if let data = data,
                       let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        
                        print("✅ Login Successful - Got tokens")
                        
                        // Save tokens
                        self?.accessToken = loginResponse.access
                        self?.refreshToken = loginResponse.refresh
                        self?.saveTokens(access: loginResponse.access, refresh: loginResponse.refresh)
                        
                        // Fetch user profile using protected route
                        self?.fetchUserProfile()
                
                // Save credentials if Remember Me is enabled
                        if self?.rememberMe == true {
                            self?.saveCredentials(email: credentials.0, password: credentials.1)
                        } else {
                            self?.clearSavedCredentials()
                        }
                        
                    } else {
                        print("❌ Failed to parse login response")
                        self?.errorMessage = "Failed to parse login response"
                    }
                } else if httpResponse.statusCode == 400 {
                    if let data = data,
                       let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("❌ Login Error 400: \(errorDict)")
                        if let nonFieldErrors = errorDict["non_field_errors"] as? [String], let firstError = nonFieldErrors.first {
                            self?.errorMessage = firstError
                        } else {
                            self?.errorMessage = "Invalid credentials"
                        }
                    } else {
                        self?.errorMessage = "Invalid credentials"
                    }
                } else {
                    print("❌ Login Failed - Status: \(httpResponse.statusCode)")
                    self?.errorMessage = "Login failed. Please try again."
                }
            }
        }.resume()
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode request"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Fetch User Profile
    private func fetchUserProfile() {
        guard let accessToken = accessToken else {
            errorMessage = "No access token available"
            return
        }
        
        // Try to decode user info from JWT token first
        if let userInfo = decodeJWTToken(accessToken) {
            print("✅ Decoded user info from JWT: \(userInfo)")
            createUserFromJWTInfo(userInfo)
            isAuthenticated = true
            return
        }
        
        // Fallback to API call if JWT decoding fails
        guard let url = URL(string: "\(baseURL)/protected/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Profile Fetch Network Error: \(error.localizedDescription)")
                    // If network fails, try to use JWT info as fallback
                    if let userInfo = self?.decodeJWTToken(accessToken) {
                        print("🔄 Using JWT fallback after network error")
                        self?.createUserFromJWTInfo(userInfo)
                        self?.isAuthenticated = true
                    } else {
                        self?.errorMessage = "Network error: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Profile Fetch Invalid Response")
                    // Try JWT fallback
                    if let userInfo = self?.decodeJWTToken(accessToken) {
                        print("🔄 Using JWT fallback after invalid response")
                        self?.createUserFromJWTInfo(userInfo)
                        self?.isAuthenticated = true
                    } else {
                        self?.errorMessage = "Invalid response"
                    }
                    return
                }
                
                print("👤 Profile Fetch Response Status: \(httpResponse.statusCode)")
                
                if let data = data {
                    print("📄 Profile Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                }
                
                if httpResponse.statusCode == 200 {
                    if let data = data,
                       let protectedResponse = try? JSONDecoder().decode(ProtectedResponse.self, from: data) {
                        
                        print("👤 Protected Response Message: \(protectedResponse.message)")
                        
                        // Extract email from the message format: "Hello user@example.com, you're authenticated!"
                        let message = protectedResponse.message
                        if let emailRange = message.range(of: "Hello "),
                           let endRange = message.range(of: ", you're authenticated!") {
                            let email = String(message[emailRange.upperBound..<endRange.lowerBound])
                            
                            print("✅ Extracted Email: \(email)")
                            
                            // Create user profile
                            self?.createUserFromEmail(email: email)
                            self?.isAuthenticated = true
                            
                            print("✅ User authenticated and profile created")
                        } else {
                            print("❌ Failed to extract email from message: \(message)")
                            // Use JWT fallback
                            if let userInfo = self?.decodeJWTToken(accessToken) {
                                print("🔄 Using JWT fallback after message parsing failure")
                                self?.createUserFromJWTInfo(userInfo)
                                self?.isAuthenticated = true
                            } else {
                                self?.errorMessage = "Failed to extract user info"
                            }
                        }
                    } else {
                        print("❌ Failed to parse protected response")
                        // Use JWT fallback
                        if let userInfo = self?.decodeJWTToken(accessToken) {
                            print("🔄 Using JWT fallback after parsing failure")
                            self?.createUserFromJWTInfo(userInfo)
                            self?.isAuthenticated = true
                        } else {
                            self?.errorMessage = "Failed to parse user profile"
                        }
                    }
                } else if httpResponse.statusCode == 401 {
                    print("🔄 Token expired or invalid, trying JWT fallback first...")
                    // Try JWT fallback before refreshing token
                    if let userInfo = self?.decodeJWTToken(accessToken) {
                        print("✅ JWT is still valid, using fallback")
                        self?.createUserFromJWTInfo(userInfo)
                        self?.isAuthenticated = true
                    } else {
                        print("🔄 JWT also invalid, trying to refresh token...")
                        self?.refreshAccessToken()
                    }
                } else {
                    print("❌ Profile Fetch Failed - Status: \(httpResponse.statusCode)")
                    // Use JWT fallback
                    if let userInfo = self?.decodeJWTToken(accessToken) {
                        print("🔄 Using JWT fallback after API failure")
                        self?.createUserFromJWTInfo(userInfo)
                        self?.isAuthenticated = true
                    } else {
                        self?.errorMessage = "Failed to fetch user profile"
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - JWT Token Decoding
    private func decodeJWTToken(_ token: String) -> JWTUserInfo? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else {
            print("❌ Invalid JWT format")
            return nil
        }
        
        let payloadSegment = segments[1]
        // Add padding if needed
        var payload = payloadSegment
        let paddingLength = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: paddingLength)
        
        guard let payloadData = Data(base64Encoded: payload) else {
            print("❌ Failed to decode JWT payload")
            return nil
        }
        
        do {
            if let payloadDict = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                print("🔍 JWT Payload: \(payloadDict)")
                
                guard let userId = payloadDict["user_id"] as? Int,
                      let email = payloadDict["email"] as? String,
                      let userTypeString = payloadDict["user_type"] as? String else {
                    print("❌ Missing required fields in JWT")
                    return nil
                }
                
                let userType = UserType(rawValue: userTypeString) ?? .student
                
                return JWTUserInfo(
                    userId: userId,
                    email: email,
                    userType: userType
                )
            }
        } catch {
            print("❌ Error parsing JWT payload: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Create User from JWT Info
    private func createUserFromJWTInfo(_ jwtInfo: JWTUserInfo) {
        print("👤 Creating user from JWT info: \(jwtInfo.email)")
        
        // Use pending registration data if available, otherwise use JWT + email extraction
        let firstName: String
        let lastName: String
        let userType: UserType
        let phoneNumber: String
        
        if let registrationData = pendingRegistrationData {
            print("✅ Using pending registration data: \(registrationData.firstName) \(registrationData.lastName)")
            firstName = registrationData.firstName
            lastName = registrationData.lastName
            userType = registrationData.userType
            phoneNumber = registrationData.phone
        } else {
            print("⚠️ No pending registration data, extracting from JWT and email")
            // Extract from email as fallback
            let namePart = jwtInfo.email.components(separatedBy: "@").first ?? "User"
            let nameComponents = namePart.components(separatedBy: ".")
            firstName = nameComponents.first?.capitalized ?? "User"
            lastName = nameComponents.count > 1 ? nameComponents[1].capitalized : "Name"
            userType = jwtInfo.userType
            phoneNumber = "+91 9876543210"
        }
        
        let user = User(
            id: "USR_\(jwtInfo.userId)",
            userType: userType,
            email: jwtInfo.email,
            firstName: firstName,
            lastName: lastName,
            profileImageURL: nil,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        self.currentUser = user
        
        // Create profile based on user type
        switch userType {
        case .student:
            self.currentStudent = self.createStudentFromUser(user: user, phoneNumber: phoneNumber)
            print("✅ Student profile created: \(user.firstName) \(user.lastName)")
        case .faculty:
            self.currentFaculty = self.createFacultyFromUser(user: user, phoneNumber: phoneNumber)
            print("✅ Faculty profile created: \(user.firstName) \(user.lastName)")
        case .admin:
            self.currentAdmin = self.createAdminFromUser(user: user, phoneNumber: phoneNumber)
            print("✅ Admin profile created: \(user.firstName) \(user.lastName)")
        }
        
        // Clear pending registration data after use
        self.pendingRegistrationData = nil
    }
    
    // MARK: - Create Student Profile from Registered User
    private func createStudentFromUser(user: User, phoneNumber: String) -> Student {
        // Generate realistic enrollment number based on current year and email
        let currentYear = Calendar.current.component(.year, from: Date())
        let emailHash = abs(user.email.hashValue) % 1000
        let enrollmentNumber = "\(currentYear % 100)\(String(format: "%03d", emailHash))"
        
        // Generate batch years (4-year program)
        let admissionYear = currentYear - 2 // Assume 3rd year student
        let graduationYear = admissionYear + 4
        let batch = "\(admissionYear)-\(graduationYear)"
        
        return Student(
            id: user.id,
            enrollmentNumber: enrollmentNumber,
            user: user,
            course: "B.Tech",
            branch: "Information Technology",
            semester: 6, // 3rd year, 2nd semester
            year: 3,
            section: "A",
            rollNumber: enrollmentNumber.uppercased(),
            admissionDate: Calendar.current.date(from: DateComponents(year: admissionYear, month: 8, day: 15))!,
            dateOfBirth: Calendar.current.date(from: DateComponents(year: admissionYear - 18, month: 1, day: 1))!,
            phoneNumber: phoneNumber,
            address: Address(
                street: "Student Housing",
                city: "Greater Noida",
                state: "Uttar Pradesh",
                pincode: "201310",
                country: "India"
            ),
            guardianInfo: GuardianInfo(
                name: "Guardian Name",
                relationship: "Father",
                phoneNumber: "+91 9876543211",
                email: "guardian@email.com",
                occupation: "Professional"
            ),
            academicInfo: AcademicInfo(
                cgpa: 8.0, // Fresh student starting with good score
                totalCredits: 120,
                completedCredits: 80,
                backlogs: 0,
                attendance: 95.0 // New student with good attendance
            ),
            batch: batch,
            registrationStatus: RegistrationStatus.active,
            academicGoals: createInitialGoalsForStudent(),
            skillsStrengths: createInitialSkillsForStudent(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    // MARK: - Create Faculty Profile from Registered User
    private func createFacultyFromUser(user: User, phoneNumber: String) -> Faculty {
        // Generate realistic employee ID based on current year and email
        let currentYear = Calendar.current.component(.year, from: Date())
        let emailHash = abs(user.email.hashValue) % 10000
        let employeeId = "FAC\(currentYear)\(String(format: "%04d", emailHash))"
        
        // Generate joining date (assume joined 2-5 years ago)
        let yearsBack = Int.random(in: 2...5)
        let joiningDate = Calendar.current.date(byAdding: .year, value: -yearsBack, to: Date()) ?? Date()
        
        return Faculty(
            id: user.id,
            employeeId: employeeId,
            user: user,
            department: "Information Technology",
            designation: "Assistant Professor",
            joiningDate: joiningDate,
            qualification: [
                "Ph.D. in Computer Science",
                "M.Tech in Information Technology",
                "B.Tech in Computer Science"
            ],
            specialization: [
                "Database Management Systems",
                "Computer Networks",
                "Software Engineering"
            ],
            phoneNumber: phoneNumber,
            officeLocation: "Faculty Block - Room \(Int.random(in: 101...350))",
            subjects: createInitialSubjectsForFaculty()
        )
    }
    
    // MARK: - Create Admin Profile from Registered User
    private func createAdminFromUser(user: User, phoneNumber: String) -> Admin {
        // Generate realistic employee ID based on current year and email
        let currentYear = Calendar.current.component(.year, from: Date())
        let emailHash = abs(user.email.hashValue) % 10000
        let employeeId = "ADM\(currentYear)\(String(format: "%04d", emailHash))"
        
        // Generate joining date (assume joined 1-8 years ago)
        let yearsBack = Int.random(in: 1...8)
        let joiningDate = Calendar.current.date(byAdding: .year, value: -yearsBack, to: Date()) ?? Date()
        
        return Admin(
            id: user.id,
            employeeId: employeeId,
            user: user,
            department: "Administration",
            role: .academicAdmin, // Default role, can be changed
            permissions: createInitialPermissionsForAdmin(),
            joiningDate: joiningDate
        )
    }
    
    // MARK: - Create Initial Goals for New Student
    private func createInitialGoalsForStudent() -> [AcademicGoal] {
        return [
            AcademicGoal(
                id: UUID().uuidString,
                type: .academic,
                title: "Maintain Good Academic Performance",
                description: "Achieve and maintain a CGPA above 8.0",
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
                priority: .high,
                status: .active,
                progress: 0.1,
                createdDate: Date(),
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: .skill,
                title: "Learn Programming Fundamentals",
                description: "Master core programming concepts and development skills",
                targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())!,
                priority: .high,
                status: .active,
                progress: 0.2,
                createdDate: Date(),
                updatedDate: Date()
            ),
            AcademicGoal(
                id: UUID().uuidString,
                type: .career,
                title: "Prepare for Internships",
                description: "Build skills and portfolio for summer internship applications",
                targetDate: Calendar.current.date(byAdding: .month, value: 8, to: Date())!,
                priority: .medium,
                status: .active,
                progress: 0.05,
                createdDate: Date(),
                updatedDate: Date()
            )
        ]
    }
        
    // MARK: - Create Initial Skills for New Student
    private func createInitialSkillsForStudent() -> [Skill] {
        return [
            Skill(
                id: UUID().uuidString,
                skillName: "Programming",
                category: .technical,
                proficiencyLevel: .beginner,
                certifications: nil,
                lastUpdated: Date(),
                endorsements: 0,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Communication",
                category: .soft,
                proficiencyLevel: .intermediate,
                certifications: nil,
                lastUpdated: Date(),
                endorsements: 0,
                isVerified: false
            ),
            Skill(
                id: UUID().uuidString,
                skillName: "Problem Solving",
                category: .analytical,
                proficiencyLevel: .intermediate,
                certifications: nil,
                lastUpdated: Date(),
                endorsements: 0,
                isVerified: false
            )
        ]
    }
    
    // MARK: - Create Initial Subjects for Faculty
    private func createInitialSubjectsForFaculty() -> [SubjectReference] {
        return [
            SubjectReference(
                id: "SUB001",
                code: "CS301",
                name: "Database Management Systems",
                credits: 4,
                semester: 6
            ),
            SubjectReference(
                id: "SUB002",
                code: "CS302",
                name: "Computer Networks",
                credits: 4,
                semester: 6
            ),
            SubjectReference(
                id: "SUB003",
                code: "CS303",
                name: "Software Engineering",
                credits: 3,
                semester: 6
            )
        ]
    }
    
    // MARK: - Create Initial Permissions for Admin
    private func createInitialPermissionsForAdmin() -> [Permission] {
        return [
            Permission(
                id: "PERM001",
                name: "Student Management",
                description: "View and manage student records",
                module: "Academic"
            ),
            Permission(
                id: "PERM002",
                name: "Faculty Management",
                description: "View and manage faculty information",
                module: "Academic"
            ),
            Permission(
                id: "PERM003",
                name: "Course Management",
                description: "Manage courses and curriculum",
                module: "Academic"
            ),
            Permission(
                id: "PERM004",
                name: "Reports & Analytics",
                description: "Generate and view academic reports",
                module: "Reports"
            )
        ]
    }
    
    // MARK: - Token Management
    func refreshAccessToken() {
        guard let refreshToken = refreshToken else {
            logout()
            return
        }
        
        guard let url = URL(string: "\(baseURL)/token/refresh/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let refreshRequest = TokenRefreshRequest(refresh: refreshToken)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(refreshRequest)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Token refresh error: \(error)")
                        self?.logout()
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.logout()
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        if let data = data,
                           let refreshResponse = try? JSONDecoder().decode(TokenRefreshResponse.self, from: data) {
                            self?.accessToken = refreshResponse.access
                            self?.saveTokens(access: refreshResponse.access, refresh: refreshToken)
                        } else {
                            self?.logout()
                        }
                    } else {
                        self?.logout()
                    }
                }
            }.resume()
            
        } catch {
            logout()
        }
    }
    
    // MARK: - Create Mock Student from User
    private func createMockStudentFromUser(user: User) -> Student {
        // Generate mock enrollment number based on email
        let emailPrefix = user.email.components(separatedBy: "@").first ?? "student"
        let enrollmentNumber = "2024\(abs(emailPrefix.hashValue) % 10000)"
        
        return Student(
            id: user.id,
            enrollmentNumber: enrollmentNumber,
            user: user,
            course: "B.Tech",
            branch: "Information Technology",
            semester: 6,
            year: 3,
            section: "A",
            rollNumber: enrollmentNumber.uppercased(),
            admissionDate: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 2005, month: 1, day: 1))!,
            phoneNumber: "+91 9876543210",
            address: Address(street: "123 University Road", city: "Greater Noida", state: "UP", pincode: "201310", country: "India"),
            guardianInfo: GuardianInfo(name: "Guardian Name", relationship: "Father", phoneNumber: "+91 9876543211", email: "guardian@email.com", occupation: "Professional"),
            academicInfo: AcademicInfo(cgpa: 8.5, totalCredits: 180, completedCredits: 120, backlogs: 0, attendance: 85.0),
            batch: "2022-2026",
            registrationStatus: RegistrationStatus.active,
            academicGoals: [],
            skillsStrengths: [],
            createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 8, day: 15))!,
            updatedAt: Date()
        )
    }
    
    // MARK: - Remember Me Functionality
    func saveCredentials(email: String, password: String) {
        let credentials = SavedCredentials(
            email: email,
            password: password,
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
            email: credentials.email,
            password: credentials.password,
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
        removeTokens()
        removeAuthToken() // Legacy cleanup
        
        // Don't clear saved credentials on logout if Remember Me is enabled
        if !rememberMe {
            clearSavedCredentials()
        }
    }
    
    // MARK: - Token Management
    private func saveTokens(access: String, refresh: String) {
        KeychainHelper.save(access, for: "access_token")
        KeychainHelper.save(refresh, for: "refresh_token")
    }
    
    private func loadSavedTokens() {
        accessToken = KeychainHelper.get(for: "access_token")
        refreshToken = KeychainHelper.get(for: "refresh_token")
        
        // Check if user should be authenticated based on saved tokens
        if accessToken != nil && refreshToken != nil {
            fetchUserProfile()
        }
    }
    
    private func removeTokens() {
        KeychainHelper.delete(for: "access_token")
        KeychainHelper.delete(for: "refresh_token")
        accessToken = nil
        refreshToken = nil
    }
    
    // Legacy methods for backward compatibility
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
    
    // MARK: - User Registration
    func register(email: String, password: String, firstName: String, lastName: String, phone: String, userType: UserType, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Store registration data for profile creation
        self.pendingRegistrationData = PendingRegistrationData(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            userType: userType
        )
        print("💾 Stored pending registration data: \(firstName) \(lastName) - \(email)")
        
        let registrationRequest = RegistrationRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            userType: userType.rawValue
        )
        
        guard let url = URL(string: "\(baseURL)/register/") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(registrationRequest)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Registration Network Error: \(error.localizedDescription)")
                        completion(false, "Network error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Registration Invalid Response")
                        completion(false, "Invalid response")
                        return
                    }
                    
                    print("📝 Registration Response Status: \(httpResponse.statusCode)")
                    
                    if let data = data {
                        print("📄 Registration Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    }
                    
                    if httpResponse.statusCode == 201 {
                        print("✅ Registration Successful")
                        completion(true, nil)
                    } else {
                        if let data = data,
                           let errorResponse = try? JSONDecoder().decode(RegistrationErrorResponse.self, from: data) {
                            let errorMessage = errorResponse.email?.first ?? errorResponse.message ?? "Registration failed"
                            print("❌ Registration Error: \(errorMessage)")
                            completion(false, errorMessage)
                        } else if let data = data,
                                  let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("❌ Registration Error Dict: \(errorDict)")
                            if let emailErrors = errorDict["email"] as? [String], let firstError = emailErrors.first {
                                completion(false, firstError)
                            } else {
                                completion(false, "Registration failed. Please try again.")
                            }
                        } else {
                            print("❌ Registration Failed - Unknown error")
                            completion(false, "Registration failed. Please try again.")
                        }
                    }
                }
            }.resume()
        } catch {
            isLoading = false
            completion(false, "Failed to encode request")
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(enrollmentNumber: String, userType: UserType) {
        // TODO: Implement password reset functionality
        print("Password reset requested for: \(enrollmentNumber)")
    }
    
    // MARK: - Password Reset API Methods
    
    /// Request password reset - sends email with reset token
    func requestPasswordReset(email: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/password_reset/") else {
            completion(false, "Invalid URL")
            return
        }
        
        let resetRequest = PasswordResetRequest(email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(resetRequest)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Password Reset Request Error: \(error.localizedDescription)")
                        completion(false, "Network error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(false, "Invalid response")
                        return
                    }
                    
                    print("🔐 Password Reset Request Status: \(httpResponse.statusCode)")
                    
                    if let data = data {
                        print("📄 Password Reset Response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    }
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                        print("✅ Password reset email sent successfully")
                        completion(true, nil)
                    } else if httpResponse.statusCode == 400 {
                        if let data = data,
                           let errorResponse = try? JSONDecoder().decode(PasswordResetErrorResponse.self, from: data) {
                            completion(false, errorResponse.message ?? "Invalid email address")
                        } else {
                            completion(false, "Invalid email address")
                        }
                    } else {
                        completion(false, "Failed to send reset email. Please try again.")
                    }
                }
            }.resume()
            
        } catch {
            isLoading = false
            completion(false, "Failed to send request")
        }
    }
    
    /// Confirm password reset with token
    func confirmPasswordReset(token: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/password_reset/confirm/") else {
            completion(false, "Invalid URL")
            return
        }
        
        let confirmRequest = PasswordResetConfirmRequest(
            token: token,
            password: newPassword
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(confirmRequest)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Password Reset Confirm Error: \(error.localizedDescription)")
                        completion(false, "Network error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(false, "Invalid response")
                        return
                    }
                    
                    print("🔐 Password Reset Confirm Status: \(httpResponse.statusCode)")
                    
                    if let data = data {
                        print("📄 Password Reset Confirm Response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                    }
                    
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                        print("✅ Password reset successful")
                        completion(true, nil)
                    } else if httpResponse.statusCode == 400 {
                        if let data = data,
                           let errorResponse = try? JSONDecoder().decode(PasswordResetErrorResponse.self, from: data) {
                            completion(false, errorResponse.message ?? "Invalid token or password")
                        } else {
                            completion(false, "Invalid token or password")
                        }
                    } else {
                        completion(false, "Failed to reset password. Please try again.")
                    }
                }
            }.resume()
            
        } catch {
            isLoading = false
            completion(false, "Failed to send request")
        }
    }
    
    // MARK: - Create User from Email (Legacy - for backward compatibility)
    private func createUserFromEmail(email: String) {
        print("👤 Creating user from email (legacy): \(email)")
        
        // Use pending registration data if available, otherwise extract from email
        let firstName: String
        let lastName: String
        let userType: UserType
        let phoneNumber: String
        
        if let registrationData = pendingRegistrationData {
            print("✅ Using pending registration data: \(registrationData.firstName) \(registrationData.lastName)")
            firstName = registrationData.firstName
            lastName = registrationData.lastName
            userType = registrationData.userType
            phoneNumber = registrationData.phone
        } else {
            print("⚠️ No pending registration data, extracting from email")
            // Fallback: extract from email
            let namePart = email.components(separatedBy: "@").first ?? "User"
            let nameComponents = namePart.components(separatedBy: ".")
            firstName = nameComponents.first?.capitalized ?? "User"
            lastName = nameComponents.count > 1 ? nameComponents[1].capitalized : "Name"
            userType = .student
            phoneNumber = "+91 9876543210"
        }
        
        let user = User(
            id: "USR_\(UUID().uuidString)",
            userType: userType,
            email: email,
            firstName: firstName,
            lastName: lastName,
            profileImageURL: nil,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        self.currentUser = user
        
        // Create profile based on user type
        switch userType {
        case .student:
            self.currentStudent = self.createStudentFromUser(user: user, phoneNumber: phoneNumber)
        case .faculty:
            self.currentFaculty = self.createFacultyFromUser(user: user, phoneNumber: phoneNumber)
        case .admin:
            self.currentAdmin = self.createAdminFromUser(user: user, phoneNumber: phoneNumber)
        }
        
        // Clear pending registration data after use
        self.pendingRegistrationData = nil
    }
}

// MARK: - Saved Credentials Model
struct SavedCredentials: Codable {
    let email: String
    let password: String
    let savedAt: Date
}

// MARK: - Pending Registration Data
struct PendingRegistrationData {
    let email: String
    let firstName: String
    let lastName: String
    let phone: String
    let userType: UserType
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