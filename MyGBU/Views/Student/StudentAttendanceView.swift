import SwiftUI

struct StudentAttendanceView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("📊 Attendance")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Track your attendance across all subjects")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    StudentAttendanceView()
        .environmentObject(StudentDashboardViewModel())
} 