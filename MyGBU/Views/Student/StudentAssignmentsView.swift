import SwiftUI

struct StudentAssignmentsView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("📝 Assignments")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("View and manage your assignments from all courses")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    StudentAssignmentsView()
        .environmentObject(StudentDashboardViewModel())
} 