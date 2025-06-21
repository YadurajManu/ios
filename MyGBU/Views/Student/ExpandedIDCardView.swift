import SwiftUI
import CoreImage.CIFilterBuiltins

struct ExpandedIDCardView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    @State private var cardRotation: Double = 0
    @State private var showBack = false
    
    var body: some View {
        ZStack {
            // Background Overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        dashboardViewModel.hideIDCard()
                    }
                }
            
            VStack(spacing: 16) {
                // Header with Close Button
                HStack {
                    Text("Student E-ID Card")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dashboardViewModel.hideIDCard()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                
                // ID Card
                ZStack {
                    // Card Front
                    if !showBack {
                        if let student = dashboardViewModel.currentStudent {
                            IDCardFrontView(qrData: generateQRData(for: student))
                                .environmentObject(dashboardViewModel)
                        }
                    } else {
                        IDCardBackView()
                            .environmentObject(dashboardViewModel)
                    }
                }
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        if showBack {
                            cardRotation = 0
                            showBack = false
                        } else {
                            cardRotation = 180
                            showBack = true
                        }
                    }
                }
                
                // Large QR Code Section
                if !showBack, let student = dashboardViewModel.currentStudent {
                    VStack(spacing: 12) {
                        Text("Scan QR Code for Verification")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Large QR Code
                        QRCodeView(data: generateQRData(for: student))
                            .frame(width: 120, height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .padding(8)
                        
                        // QR Info
                        VStack(spacing: 4) {
                            Text("Contains: Student ID, Course, Validity")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Verification URL: gbu.ac.in/verify/\(student.enrollmentNumber)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Instructions
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Tap to Flip")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 4) {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Scan QR")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
    
    // MARK: - Helper Functions
    
    private func generateQRData(for student: Student) -> String {
        // Create structured JSON data for QR code
        let qrData = StudentQRData(
            studentId: student.id,
            enrollmentNumber: student.enrollmentNumber,
            name: student.user.fullName,
            course: student.course,
            branch: student.branch,
            semester: student.semester,
            validUpto: "2028-08-05",
            university: "GBU",
            issueDate: ISO8601DateFormatter().string(from: Date()),
            verificationURL: "https://gbu.ac.in/verify/\(student.enrollmentNumber)"
        )
        
        // Convert to JSON string for QR code
        if let jsonData = try? JSONEncoder().encode(qrData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        // Fallback simple string format
        return "GBU_STUDENT:\(student.enrollmentNumber):\(student.user.fullName):\(student.course):\(student.branch):VALID_UPTO_2028-08-05"
    }
}

// MARK: - ID Card Front View
struct IDCardFrontView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    let qrData: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section with University Details
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    // University Logo
                    Image("GbuLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                    
                    VStack(alignment: .center, spacing: 1) {
                        Text("GAUTAM BUDDHA UNIVERSITY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        Text("Greater Noida, Uttar Pradesh")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                
                // ID Card Title
                Text("STUDENT IDENTITY CARD")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.red)
                    )
            }
            .padding(.top, 12)
            
            // Main Content Area
            HStack(spacing: 12) {
                // Left Side - Photo and Signature
                VStack(spacing: 6) {
                    // Student Photo
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 70, height: 85)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        
                        if let student = dashboardViewModel.currentStudent,
                           let imageURL = student.user.profileImageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                VStack(spacing: 4) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                    Text("PHOTO")
                                        .font(.system(size: 6, weight: .medium))
                                        .foregroundColor(.red)
                                }
                            }
                            .frame(width: 70, height: 85)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            VStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                Text("PHOTO")
                                    .font(.system(size: 6, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // Signature Area
                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 50, height: 0.5)
                        
                        Text("Student Signature")
                            .font(.system(size: 6))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                
                // Right Side - Student Details
                VStack(alignment: .leading, spacing: 4) {
                    if let student = dashboardViewModel.currentStudent {
                        IDCardRow(label: "Name", value: student.user.fullName)
                        IDCardRow(label: "Father's Name", value: student.guardianInfo.name)
                        IDCardRow(label: "Enrollment No.", value: student.enrollmentNumber.uppercased())
                        IDCardRow(label: "Course", value: student.course)
                        IDCardRow(label: "Branch", value: "Information Technology")
                        IDCardRow(label: "Semester", value: "\(student.semester)th")
                        IDCardRow(label: "DOB", value: formatDate(student.dateOfBirth))
                        IDCardRow(label: "Session", value: "2022-26")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Footer Section
            VStack(spacing: 6) {
                // Validity and ID
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Valid Up To")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.gray)
                        Text("05 August 2028")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Student ID")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.gray)
                        Text("\(dashboardViewModel.currentStudent?.id ?? "")")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                // QR Code and Authority Signature
                HStack {
                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 40, height: 0.5)
                        Text("Registrar")
                            .font(.system(size: 6))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                                         VStack(spacing: 2) {
                         // Small QR Code on Card
                         QRCodeView(data: qrData)
                             .frame(width: 35, height: 35)
                         
                         Text("Scan to Verify")
                             .font(.system(size: 5))
                             .foregroundColor(.gray)
                     }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 350, height: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private func generateQRData(for student: Student) -> String {
        // Create structured JSON data for QR code
        let qrData = StudentQRData(
            studentId: student.id,
            enrollmentNumber: student.enrollmentNumber,
            name: student.user.fullName,
            course: student.course,
            branch: student.branch,
            semester: student.semester,
            validUpto: "2028-08-05",
            university: "GBU",
            issueDate: ISO8601DateFormatter().string(from: Date()),
            verificationURL: "https://gbu.ac.in/verify/\(student.enrollmentNumber)"
        )
        
        // Convert to JSON string for QR code
        if let jsonData = try? JSONEncoder().encode(qrData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        // Fallback simple string format
        return "GBU_STUDENT:\(student.enrollmentNumber):\(student.user.fullName):\(student.course):\(student.branch):VALID_UPTO_2028-08-05"
    }
}

// MARK: - ID Card Back View
struct IDCardBackView: View {
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text("IMPORTANT INSTRUCTIONS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.top, 16)
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(number: "1", text: "This card is property of GBU and must be returned on demand.")
                InstructionRow(number: "2", text: "Loss of card should be reported immediately to the administration.")
                InstructionRow(number: "3", text: "This card must be carried at all times within the campus.")
                InstructionRow(number: "4", text: "Misuse of this card will result in disciplinary action.")
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Emergency Contact
            VStack(spacing: 4) {
                Text("Emergency Contact")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text("Security Office: +91-120-2344200")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text("Admin Office: +91-120-2344201")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)
        }
        .frame(width: 350, height: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(x: -1, y: 1) // Flip horizontally for back view
    }
}
// MARK: - Supporting Views
struct IDCardRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("\(label):")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 65, alignment: .leading)
            
            Text(value)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(width: 12)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.black)
                .lineLimit(nil)
        }
    }
}

// MARK: - QR Code Data Structure
struct StudentQRData: Codable {
    let studentId: String
    let enrollmentNumber: String
    let name: String
    let course: String
    let branch: String
    let semester: Int
    let validUpto: String
    let university: String
    let issueDate: String
    let verificationURL: String
}

// MARK: - QR Code View
struct QRCodeView: View {
    let data: String
    
    var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // Fallback if QR generation fails
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black)
                .overlay(
                    Text("QR")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        // Set error correction level to high for better scanning
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up the QR code for better quality
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    ExpandedIDCardView()
        .environmentObject(StudentDashboardViewModel())
} 