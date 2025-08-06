import Foundation
import Combine

class RegistrationService: ObservableObject {
    private let baseURL = "http://147.93.105.208:6061"
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published var schools: [School] = []
    @Published var courses: [Course] = []
    @Published var studentRegistrations: [SemesterRegistration] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - API Methods
    
    /// Fetch all available schools/departments
    func fetchSchools() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/schools/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [School].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to fetch schools: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] (schools: [School]) in
                    self?.schools = schools
                }
            )
            .store(in: &cancellables)
    }
    
    /// Fetch courses for a specific school
    func fetchCourses(for school: School) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/schools/\(school.id)/courses/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Course].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to fetch courses: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] (courses: [Course]) in
                    self?.courses = courses
                }
            )
            .store(in: &cancellables)
    }
    
    /// Get student's registration history
    func fetchStudentRegistrations(studentId: Int) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/students/\(studentId)/registrations/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SemesterRegistration].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to fetch registrations: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] registrations in
                    self?.studentRegistrations = registrations
                }
            )
            .store(in: &cancellables)
    }
    
    /// Submit semester registration
    func submitSemesterRegistration(_ registration: SemesterRegistrationRequest) -> AnyPublisher<SemesterRegistration, Error> {
        guard let url = URL(string: "\(baseURL)/api/semester-registrations/") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(registration)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SemesterRegistration.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Submit course registration
    func submitCourseRegistration(_ registration: CourseRegistrationRequest) -> AnyPublisher<CourseRegistration, Error> {
        guard let url = URL(string: "\(baseURL)/api/course-registrations/") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(registration)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CourseRegistration.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Enroll student in program
    func enrollStudentInProgram(_ enrollment: StudentEnrollmentRequest) -> AnyPublisher<StudentEnrollment, Error> {
        guard let url = URL(string: "\(baseURL)/api/enrollments/") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(enrollment)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: StudentEnrollment.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 