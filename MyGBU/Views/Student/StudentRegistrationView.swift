import SwiftUI

struct StudentRegistrationView: View {
    @ObservedObject var viewModel: StudentDashboardViewModel
    @StateObject private var registrationViewModel = RegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                
                // Content based on current step
                stepContent
                
                // Navigation Buttons
                navigationButtons
            }
            .navigationTitle("Course Registration")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Error", isPresented: .constant(registrationViewModel.errorMessage != nil)) {
                Button("OK") {
                    registrationViewModel.errorMessage = nil
                }
            } message: {
                Text(registrationViewModel.errorMessage ?? "")
            }
            .alert("Success", isPresented: .constant(registrationViewModel.successMessage != nil)) {
                Button("OK") {
                    registrationViewModel.successMessage = nil
                    dismiss()
                }
            } message: {
                Text(registrationViewModel.successMessage ?? "")
            }
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(RegistrationViewModel.RegistrationStep.allCases, id: \.self) { step in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(stepColor(for: step))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: stepIcon(for: step))
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        
                        Text(step.title)
                            .font(.caption2)
                            .foregroundColor(stepColor(for: step))
                            .multilineTextAlignment(.center)
                    }
                    
                    if step != RegistrationViewModel.RegistrationStep.allCases.last {
                        Rectangle()
                            .fill(stepColor(for: step))
                            .frame(height: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
        }
        .padding(.top, 10)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch registrationViewModel.currentStep {
        case .schoolSelection:
            SchoolSelectionView(registrationViewModel: registrationViewModel)
        case .courseSelection:
            CourseSelectionView(registrationViewModel: registrationViewModel)
        case .formCompletion:
            FormCompletionView(registrationViewModel: registrationViewModel)
        case .review:
            ReviewView(registrationViewModel: registrationViewModel)
        case .confirmation:
            ConfirmationView(registrationViewModel: registrationViewModel)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if registrationViewModel.currentStep != .schoolSelection {
                Button("Previous") {
                    registrationViewModel.previousStep()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            if registrationViewModel.currentStep == .review {
                Button("Submit Registration") {
                    if let student = viewModel.currentStudent {
                        registrationViewModel.submitRegistration(studentId: Int(student.id) ?? 1)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!registrationViewModel.isFormValid || registrationViewModel.isLoading)
            } else if registrationViewModel.currentStep != .confirmation {
                Button("Next") {
                    registrationViewModel.nextStep()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canProceedToNextStep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    private func stepColor(for step: RegistrationViewModel.RegistrationStep) -> Color {
        if step.rawValue < registrationViewModel.currentStep.rawValue {
            return .green
        } else if step == registrationViewModel.currentStep {
            return .red
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func stepIcon(for step: RegistrationViewModel.RegistrationStep) -> String {
        if step.rawValue < registrationViewModel.currentStep.rawValue {
            return "checkmark"
        } else {
            return step.icon
        }
    }
    
    private var canProceedToNextStep: Bool {
        switch registrationViewModel.currentStep {
        case .schoolSelection:
            return registrationViewModel.formData.selectedSchool != nil
        case .courseSelection:
            return !registrationViewModel.formData.selectedCourses.isEmpty
        case .formCompletion:
            return registrationViewModel.isFormValid
        case .review:
            return true
        case .confirmation:
            return true
        }
    }
}

// MARK: - Supporting Views

struct SchoolSelectionView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Your School")
                        .font(.title2)
                    .fontWeight(.bold)
                        .foregroundColor(.primary)
                
                    Text("Choose the school/department you want to register courses from")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Schools Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(registrationViewModel.availableSchools) { school in
                        SchoolCard(
                            school: school,
                            isSelected: registrationViewModel.formData.selectedSchool?.id == school.id
                        ) {
                            registrationViewModel.selectSchool(school)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                if registrationViewModel.isLoading {
                    ProgressView("Loading schools...")
                        .padding()
                }
                
                if registrationViewModel.availableSchools.isEmpty && !registrationViewModel.isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "building.2")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No schools available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Please check back later or contact your administrator")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
    }
}

struct SchoolCard: View {
    let school: School
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "building.2.fill")
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .red)
                
                VStack(spacing: 4) {
                    Text(school.schoolName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)
                        .multilineTextAlignment(.center)
                    
                    Text(school.schoolCode)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Text(school.schoolType)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.red : Color.white)
                    .shadow(color: isSelected ? .red.opacity(0.3) : .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.red)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 1)
                    .background(Color.white)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    StudentRegistrationView(viewModel: StudentDashboardViewModel())
} 