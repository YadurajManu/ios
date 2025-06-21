import SwiftUI

struct StudentRegistrationView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("📋 Registration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Register for next semester courses")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    StudentRegistrationView()
        .environmentObject(StudentDashboardViewModel())
} 