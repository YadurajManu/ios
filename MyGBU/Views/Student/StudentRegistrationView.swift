import SwiftUI

struct StudentRegistrationView: View {
    @ObservedObject var viewModel: StudentDashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Placeholder Icon
                Image(systemName: "doc.text.below.ecg")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.6))
                
                // Placeholder Text
                VStack(spacing: 12) {
                    Text("Registration")
                        .font(.title2)
                    .fontWeight(.bold)
                        .foregroundColor(.primary)
                
                    Text("This section is under development")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    StudentRegistrationView(viewModel: StudentDashboardViewModel())
} 