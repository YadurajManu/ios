import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var enrollmentNumber = ""
    @State private var password = ""
    @State private var isSecureField = true
    @State private var showUserTypeSwitcher = false
    @State private var selectedUserType: UserType = .student
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                // Main Content with ScrollView for keyboard handling
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        VStack(spacing: 0) {
                            // Header Section
                            VStack(spacing: 20) {
                                Spacer()
                                    .frame(height: geometry.safeAreaInsets.top + 20)
                                
                                // Logo
                                Image("GbuLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .red.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                // University Name
                                VStack(spacing: 12) {
                                    Text("Gautam Buddha University")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 8) {
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 30, height: 2)
                                        
                                        Text("ERP Portal")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 30, height: 2)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                            
                            Spacer()
                            
                            // Login Form
                            VStack(spacing: 24) {
                                // User Type Dropdown Selector
                                userTypeSelector
                                    .padding(.horizontal, 32)
                                
                                // Input Fields
                                VStack(spacing: 20) {
                                    // Enrollment Number Field
                                    SimpleTextField(
                                        title: getFieldTitle(),
                                        text: $enrollmentNumber,
                                        icon: getFieldIcon(),
                                        keyboardType: .default
                                    )
                                    
                                    // Password Field
                                    SimpleSecureField(
                                        title: "Password",
                                        text: $password,
                                        isSecure: $isSecureField
                                    )
                                }
                                .padding(.horizontal, 32)
                                
                                // Forgot Password
                                HStack {
                                    Spacer()
                                    Button("Forgot Password?") {
                                        authService.resetPassword(
                                            enrollmentNumber: enrollmentNumber,
                                            userType: selectedUserType
                                        )
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                }
                                .padding(.horizontal, 32)
                                
                                // Error Message
                                if let errorMessage = authService.errorMessage {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.red.opacity(0.1))
                                        )
                                        .padding(.horizontal, 32)
                                }
                                
                                // Login Button
                                Button(action: {
                                    loginUser()
                                }) {
                                    HStack(spacing: 12) {
                                        if authService.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.9)
                                        } else {
                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.title3)
                                        }
                                        
                                        Text(authService.isLoading ? "Signing In..." : "Login")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red)
                                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .disabled(enrollmentNumber.isEmpty || password.isEmpty || authService.isLoading)
                                .opacity((enrollmentNumber.isEmpty || password.isEmpty || authService.isLoading) ? 0.6 : 1.0)
                                .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .offset(y: keyboardHeight > 0 ? -keyboardHeight/4 : 0)
                .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                
                // User Type Dropdown from Right
                if showUserTypeSwitcher {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showUserTypeSwitcher = false
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            ForEach(UserType.allCases, id: \.self) { userType in
                                Button(action: {
                                    selectedUserType = userType
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showUserTypeSwitcher = false
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: userType.icon)
                                            .foregroundColor(selectedUserType == userType ? .red : .gray)
                                            .font(.system(size: 16))
                                            .frame(width: 20)
                                        
                                        Text(userType.displayName)
                                            .font(.subheadline)
                                            .fontWeight(selectedUserType == userType ? .semibold : .medium)
                                            .foregroundColor(selectedUserType == userType ? .red : .black)
                                        
                                        Spacer()
                                        
                                        if selectedUserType == userType {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        selectedUserType == userType ? 
                                            Color.red.opacity(0.1) : Color.white
                                    )
                                }
                                
                                if userType != UserType.allCases.last {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.15), radius: 20, x: -5, y: 0)
                        )
                        .frame(width: 200)
                        .offset(x: showUserTypeSwitcher ? 0 : 250)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                    .padding(.trailing, 20)
                }
            }
        }
        .onTapGesture {
            // Hide keyboard when tapping outside
            hideKeyboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func loginUser() {
        authService.login(
            enrollmentNumber: enrollmentNumber,
            password: password,
            userType: selectedUserType
        )
    }
    
    private func getFieldTitle() -> String {
        switch selectedUserType {
        case .student:
            return "Enrollment Number"
        case .faculty:
            return "Employee ID"
        case .admin:
            return "Admin ID"
        }
    }
    
    private func getFieldIcon() -> String {
        switch selectedUserType {
        case .student:
            return "person.text.rectangle"
        case .faculty:
            return "person.badge.key"
        case .admin:
            return "key.fill"
        }
    }
    
    private var userTypeSelector: some View {
        HStack {
            Text("User Type:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showUserTypeSwitcher.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: selectedUserType.icon)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    
                    Text(selectedUserType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(showUserTypeSwitcher ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - Custom Components

struct SimpleTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                TextField("Enter your \(title.lowercased())", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(text.isEmpty ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
            )
        }
    }
}

struct SimpleSecureField: View {
    let title: String
    @Binding var text: String
    @Binding var isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.red)
                    .frame(width: 20)
                
                Group {
                    if isSecure {
                        SecureField("Enter your password", text: $text)
                    } else {
                        TextField("Enter your password", text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(text.isEmpty ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
} 