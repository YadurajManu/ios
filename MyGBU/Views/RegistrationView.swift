import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    // Form Fields
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var selectedUserType: UserType = .student
    
    // UI State
    @State private var isSecureField = true
    @State private var isConfirmSecureField = true
    @State private var showUserTypeSwitcher = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var validationErrors: [String] = []
    @State private var showSuccess = false
    
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
                                // Close Button
                                HStack {
                                    Button(action: { dismiss() }) {
                                        Image(systemName: "xmark")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                            .padding(8)
                                            .background(Circle().fill(Color.gray.opacity(0.1)))
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, geometry.safeAreaInsets.top + 10)
                                
                                // Logo
                                Image("GbuLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .red.opacity(0.2), radius: 8, x: 0, y: 4)
                                
                                // Title
                                VStack(spacing: 8) {
                                    Text("Create Account")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("Join Gautam Buddha University")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.bottom, 30)
                            
                            // Registration Form
                            VStack(spacing: 24) {
                                // User Type Selector
                                userTypeSelector
                                    .padding(.horizontal, 32)
                                
                                // Input Fields
                                VStack(spacing: 16) {
                                    // Name Fields
                                    HStack(spacing: 12) {
                                        RegistrationTextField(
                                            title: "First Name",
                                            text: $firstName,
                                            icon: "person.fill",
                                            keyboardType: .default
                                        )
                                        
                                        RegistrationTextField(
                                            title: "Last Name",
                                            text: $lastName,
                                            icon: "person.fill",
                                            keyboardType: .default
                                        )
                                    }
                                    
                                    // Email Field
                                    RegistrationTextField(
                                        title: "Email Address",
                                        text: $email,
                                        icon: "envelope.fill",
                                        keyboardType: .emailAddress
                                    )
                                    
                                    // Phone Field
                                    RegistrationTextField(
                                        title: "Phone Number",
                                        text: $phone,
                                        icon: "phone.fill",
                                        keyboardType: .phonePad
                                    )
                                    
                                    // Password Fields
                                    RegistrationSecureField(
                                        title: "Password",
                                        text: $password,
                                        isSecure: $isSecureField
                                    )
                                    
                                    RegistrationSecureField(
                                        title: "Confirm Password",
                                        text: $confirmPassword,
                                        isSecure: $isConfirmSecureField
                                    )
                                }
                                .padding(.horizontal, 32)
                                
                                // Validation Errors
                                if !validationErrors.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(validationErrors, id: \.self) { error in
                                            HStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                                
                                                Text(error)
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red.opacity(0.1))
                                    )
                                    .padding(.horizontal, 32)
                                }
                                
                                // API Error Message
                                if let errorMessage = errorMessage {
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
                                
                                // Terms and Conditions
                                VStack(spacing: 8) {
                                    Text("By creating an account, you agree to our")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 4) {
                                        Button("Terms of Service") {
                                            // TODO: Show terms
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        
                                        Text("and")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Button("Privacy Policy") {
                                            // TODO: Show privacy policy
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 32)
                                
                                // Register Button
                                Button(action: {
                                    registerUser()
                                }) {
                                    HStack(spacing: 12) {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.9)
                                        } else {
                                            Image(systemName: "person.badge.plus")
                                                .font(.title3)
                                        }
                                        
                                        Text(isLoading ? "Creating Account..." : "Create Account")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isFormValid ? Color.red : Color.gray)
                                            .shadow(color: isFormValid ? .red.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                    )
                                }
                                .disabled(!isFormValid || isLoading)
                                .padding(.horizontal, 32)
                                
                                // Login Link
                                HStack(spacing: 4) {
                                    Text("Already have an account?")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Button("Sign In") {
                                        dismiss()
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                }
                                .padding(.top, 8)
                            }
                            
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .offset(y: keyboardHeight > 0 ? -keyboardHeight/3 : 0)
                .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                
                // User Type Dropdown
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
                
                // Success Overlay
                if showSuccess {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome to GBU!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Hi \(firstName)! Your account has been created successfully. You're being logged in automatically.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 15)
                    )
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onTapGesture {
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
    
    // MARK: - Helper Views
    
    private var userTypeSelector: some View {
        HStack {
            Text("Account Type:")
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
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               !phone.isEmpty &&
               isValidEmail(email) &&
               password == confirmPassword &&
               password.count >= 8
    }
    
    // MARK: - Functions
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func validateForm() -> Bool {
        validationErrors.removeAll()
        
        // Name validation
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("First name is required")
        }
        
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Last name is required")
        }
        
        // Email validation
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Email is required")
        } else if !isValidEmail(email) {
            validationErrors.append("Please enter a valid email address")
        }
        
        // Phone validation
        if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Phone number is required")
        } else if phone.count < 10 {
            validationErrors.append("Phone number must be at least 10 digits")
        }
        
        // Password validation
        if password.isEmpty {
            validationErrors.append("Password is required")
        } else if password.count < 8 {
            validationErrors.append("Password must be at least 8 characters long")
        }
        
        if confirmPassword.isEmpty {
            validationErrors.append("Please confirm your password")
        } else if password != confirmPassword {
            validationErrors.append("Passwords do not match")
        }
        
        return validationErrors.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func registerUser() {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        authService.register(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            userType: selectedUserType
        ) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    showSuccess = true
                    
                    // Auto-login after successful registration
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        authService.login(
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            password: password,
                            rememberMe: true
                        )
                        
                        // Dismiss registration view after login attempt
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
                } else {
                    errorMessage = error ?? "Registration failed. Please try again."
                }
            }
        }
    }
}

// MARK: - Custom Text Field Components

struct RegistrationTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .frame(width: 16)
                    .font(.system(size: 14))
                
                TextField("Enter \(title.lowercased())", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(text.isEmpty ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
            )
        }
    }
}

struct RegistrationSecureField: View {
    let title: String
    @Binding var text: String
    @Binding var isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.red)
                    .frame(width: 16)
                    .font(.system(size: 14))
                
                Group {
                    if isSecure {
                        SecureField("Enter \(title.lowercased())", text: $text)
                    } else {
                        TextField("Enter \(title.lowercased())", text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(text.isEmpty ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthenticationService())
} 