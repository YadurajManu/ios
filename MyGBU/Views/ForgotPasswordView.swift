import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var showSuccessMessage = false
    @State private var showResetPasswordView = false
    @State private var resetToken = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color.white
                        .ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 32) {
                            Spacer()
                                .frame(height: geometry.safeAreaInsets.top + 20)
                            
                            // Header Section
                            VStack(spacing: 20) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "lock.rotation")
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                
                                // Title and Description
                                VStack(spacing: 12) {
                                    Text("Forgot Password?")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("Don't worry! Enter your email address and we'll send you a link to reset your password.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                        .padding(.horizontal, 20)
                                }
                            }
                            
                            if !showSuccessMessage {
                                // Email Input Form
                                VStack(spacing: 24) {
                                    // Email Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Email Address")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                        
                                        HStack(spacing: 12) {
                                            Image(systemName: "envelope.fill")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                                .frame(width: 20)
                                            
                                            TextField("Enter your email", text: $email)
                                                .font(.subheadline)
                                                .keyboardType(.emailAddress)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
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
                                    
                                    // Send Reset Link Button
                                    Button(action: sendResetEmail) {
                                        HStack(spacing: 12) {
                                            if authService.isLoading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.9)
                                            } else {
                                                Image(systemName: "paperplane.fill")
                                                    .font(.title3)
                                            }
                                            
                                            Text(authService.isLoading ? "Sending..." : "Send Reset Link")
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
                                    .disabled(email.isEmpty || authService.isLoading)
                                    .opacity((email.isEmpty || authService.isLoading) ? 0.6 : 1.0)
                                    .padding(.horizontal, 32)
                                }
                            } else {
                                // Success Message
                                VStack(spacing: 24) {
                                    // Success Icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Text("Email Sent!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                        Text("We've sent a password reset link to \(email). Please check your email and follow the instructions to reset your password.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                    // Manual Token Entry (for testing)
                                    VStack(spacing: 16) {
                                        Text("For testing: Enter reset token manually")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Reset Token", text: $resetToken)
                                            .font(.caption)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.horizontal, 32)
                                        
                                        Button("Reset Password with Token") {
                                            if !resetToken.isEmpty {
                                                showResetPasswordView = true
                                            }
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .disabled(resetToken.isEmpty)
                                    }
                                    .padding(.top, 20)
                                }
                                .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                            
                            // Back to Login
                            Button("Back to Login") {
                                dismiss()
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(.bottom, 20)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showResetPasswordView) {
            ResetPasswordView(resetToken: resetToken)
                .environmentObject(authService)
        }
    }
    
    private func sendResetEmail() {
        authService.requestPasswordReset(email: email) { success, error in
            if success {
                showSuccessMessage = true
            } else {
                // Error is already set in authService.errorMessage
                print("Reset email failed: \(error ?? "Unknown error")")
            }
        }
    }
}

// MARK: - Reset Password View
struct ResetPasswordView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    let resetToken: String
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSecureField1 = true
    @State private var isSecureField2 = true
    @State private var showSuccessMessage = false
    
    var isPasswordValid: Bool {
        newPassword.count >= 8 && newPassword == confirmPassword
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 32) {
                            Spacer()
                                .frame(height: geometry.safeAreaInsets.top + 20)
                            
                            if !showSuccessMessage {
                                // Header
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Text("Reset Password")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        Text("Create a new secure password for your account")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                                // Password Form
                                VStack(spacing: 24) {
                                    // New Password Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("New Password")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        HStack(spacing: 12) {
                                            Image(systemName: "lock.fill")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                                .frame(width: 20)
                                            
                                            if isSecureField1 {
                                                SecureField("Enter new password", text: $newPassword)
                                                    .font(.subheadline)
                                            } else {
                                                TextField("Enter new password", text: $newPassword)
                                                    .font(.subheadline)
                                            }
                                            
                                            Button(action: { isSecureField1.toggle() }) {
                                                Image(systemName: isSecureField1 ? "eye.slash.fill" : "eye.fill")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    // Confirm Password Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Confirm Password")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        HStack(spacing: 12) {
                                            Image(systemName: "lock.fill")
                                                .font(.title3)
                                                .foregroundColor(.gray)
                                                .frame(width: 20)
                                            
                                            if isSecureField2 {
                                                SecureField("Confirm new password", text: $confirmPassword)
                                                    .font(.subheadline)
                                            } else {
                                                TextField("Confirm new password", text: $confirmPassword)
                                                    .font(.subheadline)
                                            }
                                            
                                            Button(action: { isSecureField2.toggle() }) {
                                                Image(systemName: isSecureField2 ? "eye.slash.fill" : "eye.fill")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(newPassword != confirmPassword && !confirmPassword.isEmpty ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    // Password Requirements
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Password Requirements:")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.gray)
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: newPassword.count >= 8 ? "checkmark.circle.fill" : "circle")
                                                .font(.caption)
                                                .foregroundColor(newPassword.count >= 8 ? .green : .gray)
                                            
                                            Text("At least 8 characters")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: newPassword == confirmPassword && !newPassword.isEmpty ? "checkmark.circle.fill" : "circle")
                                                .font(.caption)
                                                .foregroundColor(newPassword == confirmPassword && !newPassword.isEmpty ? .green : .gray)
                                            
                                            Text("Passwords match")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Error Message
                                    if let errorMessage = authService.errorMessage {
                                        Text(errorMessage)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
                                    // Reset Password Button
                                    Button(action: resetPassword) {
                                        HStack(spacing: 12) {
                                            if authService.isLoading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.9)
                                            } else {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title3)
                                            }
                                            
                                            Text(authService.isLoading ? "Resetting..." : "Reset Password")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue)
                                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                        )
                                    }
                                    .disabled(!isPasswordValid || authService.isLoading)
                                    .opacity((!isPasswordValid || authService.isLoading) ? 0.6 : 1.0)
                                }
                                .padding(.horizontal, 32)
                            } else {
                                // Success Message
                                VStack(spacing: 24) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        Text("Password Reset Successfully!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("Your password has been reset. You can now login with your new password.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    Button("Back to Login") {
                                        dismiss()
                                    }
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetPassword() {
        authService.confirmPasswordReset(token: resetToken, newPassword: newPassword) { success, error in
            if success {
                showSuccessMessage = true
            } else {
                print("Password reset failed: \(error ?? "Unknown error")")
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationService())
} 