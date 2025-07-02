import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isSecureField = true
    @State private var keyboardHeight: CGFloat = 0
    @State private var rememberMe = false
    @State private var showRegistration = false

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
                                // Input Fields
                                VStack(spacing: 20) {
                                    // Email Field
                                    SimpleTextField(
                                        title: "Email Address",
                                        text: $email,
                                        icon: "envelope.fill",
                                        keyboardType: .emailAddress
                                    )
                                    
                                    // Password Field
                                    SimpleSecureField(
                                        title: "Password",
                                        text: $password,
                                        isSecure: $isSecureField
                                    )
                                }
                                .padding(.horizontal, 32)
                                
                                // Remember Me & Forgot Password
                                HStack {
                                    // Remember Me Checkbox
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            rememberMe.toggle()
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(rememberMe ? Color.red : Color.clear)
                                                    .frame(width: 18, height: 18)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .stroke(rememberMe ? Color.red : Color.gray.opacity(0.5), lineWidth: 1.5)
                                                    )
                                                
                                                if rememberMe {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .transition(.scale.combined(with: .opacity))
                                                }
                                            }
                                            
                                            Text("Remember Me")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Forgot Password?") {
                                        // TODO: Implement password reset
                                        print("Password reset for: \(email)")
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
                                .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                                .opacity((email.isEmpty || password.isEmpty || authService.isLoading) ? 0.6 : 1.0)
                                .padding(.horizontal, 32)
                                
                                // Register Link
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Button("Create Account") {
                                        showRegistration = true
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                }
                                .padding(.top, 16)
                            }
                            
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .offset(y: keyboardHeight > 0 ? -keyboardHeight/4 : 0)
                .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
                

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
        .onAppear {
            loadSavedCredentials()
        }
        .sheet(isPresented: $showRegistration) {
            RegistrationView()
                .environmentObject(authService)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func loadSavedCredentials() {
        if let savedCredentials = authService.savedCredentials {
            email = savedCredentials.email
            password = savedCredentials.password
            rememberMe = true
        }
    }
    
    private func loginUser() {
        authService.login(
            email: email,
            password: password,
            rememberMe: rememberMe
        )
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