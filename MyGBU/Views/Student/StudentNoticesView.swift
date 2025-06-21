import SwiftUI

struct StudentNoticesView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("📢 Notices")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("Stay updated with university announcements")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

#Preview {
    StudentNoticesView()
        .environmentObject(StudentDashboardViewModel())
} 