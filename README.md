# 🎓 MyGBU - University ERP Platform

## 📋 Project Overview

**MyGBU** is a comprehensive iOS-based Enterprise Resource Planning (ERP) platform designed for **Gautam Buddha University**. Built with modern SwiftUI architecture, it provides a complete digital ecosystem for students, faculty, and administrators to manage university operations efficiently.

### 🏛️ University Information
- **Institution**: Gautam Buddha University (GBU)
- **Location**: Greater Noida, Uttar Pradesh, India
- **Platform**: iOS (iPhone/iPad)
- **Framework**: SwiftUI with MVVM Architecture

---

## ✨ Features Implemented

### 🔐 Authentication System
- **Multi-User Login**: Support for Students, Faculty, and Admin
- **Secure Authentication**: Keychain integration for token storage
- **Mock Authentication**: Demo system ready for API integration
- **Password Security**: Secure field with show/hide functionality
- **Keyboard Handling**: Smart UI adjustment when keyboard appears

#### Demo Account:
```
User Type: Student
Enrollment: 245uai130
Password: Yadu@1234
Student: Yaduraj Singh (SOICT - Information Technology)
```

### 📱 Student Dashboard

#### 🏠 Home Tab Features:
- **Typewriter Greeting Effect**: Dynamic "Good Morning/Afternoon/Evening" animation
- **Hero Profile E-ID Card**: Tappable card showing student overview
- **Quick Action Buttons**: Fast access to Attendance, Assignments, Registration
- **Recent Notices**: University announcements and updates
- **Logout Functionality**: Secure session management

#### 🆔 Virtual E-ID Card System:
- **Professional Design**: University-branded ID card layout
- **Complete Student Information**:
  - Student photo placeholder
  - Full name and father's name
  - Enrollment number and course details
  - Date of birth and validity period
  - QR code for verification
- **Interactive Features**:
  - Tap to expand to full-screen modal
  - Flip animation to view front/back of card
  - Professional layout matching real university IDs

#### 📊 QR Code Integration:
- **Functional QR Codes**: Real QR generation using Core Image
- **Structured Data**: JSON format containing complete student information
- **Database Ready**: Verification URL placeholder for backend integration
- **Security Features**: High error correction for reliable scanning

#### QR Code Data Structure:
```json
{
  "studentId": "STU245UAI130",
  "enrollmentNumber": "245uai130",
  "name": "Yaduraj Singh",
  "course": "B.Tech",
  "branch": "Information Technology",
  "semester": 6,
  "validUpto": "2028-08-05",
  "university": "GBU",
  "issueDate": "2024-12-19T06:29:00Z",
  "verificationURL": "https://gbu.ac.in/verify/245uai130"
}
```

#### 🗂️ Tab Navigation:
- **Home**: Main dashboard with overview
- **Attendance**: Student attendance tracking (placeholder)
- **Assignments**: Course assignments management (placeholder)
- **Registration**: Next semester course registration (placeholder)
- **Notices**: University announcements (placeholder)

---

## 🏗️ Technical Architecture

### 📁 Project Structure
```
MyGBU/
├── MyGBUApp.swift                 # App entry point
├── Models/
│   └── User.swift                 # Data models for all user types
├── Services/
│   └── AuthenticationService.swift # Authentication & API services
├── Views/
│   ├── LoginView.swift            # Login interface
│   └── Student/                   # Student-specific views
│       ├── StudentDashboardView.swift
│       ├── StudentHomeView.swift
│       ├── ExpandedIDCardView.swift
│       ├── StudentAttendanceView.swift
│       ├── StudentAssignmentsView.swift
│       ├── StudentRegistrationView.swift
│       └── StudentNoticesView.swift
├── ViewModels/
│   └── Student/
│       └── StudentDashboardViewModel.swift
└── Assets.xcassets/              # App icons and images
```

### 🔧 Architecture Pattern: MVVM
- **Models**: Data structures and business logic
- **Views**: SwiftUI user interface components
- **ViewModels**: Reactive state management with Combine framework
- **Services**: API integration and external service handling

### 🛠️ Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Core Image**: QR code generation
- **Keychain Services**: Secure token storage
- **Foundation**: Core Swift functionality

---

## 🗄️ Database Integration Readiness

### 📊 Data Models

#### User Types Supported:
1. **Student**: Complete academic profile
2. **Faculty**: Employee and teaching information
3. **Admin**: Administrative roles and permissions

#### Student Data Model:
```swift
struct Student {
    let id: String
    let enrollmentNumber: String
    let user: User
    let course: String
    let branch: String
    let semester: Int
    let year: Int
    let section: String?
    let rollNumber: String
    let admissionDate: Date
    let dateOfBirth: Date
    let phoneNumber: String
    let address: Address
    let guardianInfo: GuardianInfo
    let academicInfo: AcademicInfo
}
```

#### Supporting Models:
- **Address**: Complete address information
- **GuardianInfo**: Parent/guardian details
- **AcademicInfo**: CGPA, credits, attendance
- **AttendanceOverview**: Subject-wise attendance tracking
- **Assignment**: Course assignments with priorities
- **Notice**: University announcements with categories

### 🔌 API Integration Points

#### Authentication Endpoints:
```
POST /auth/login
POST /auth/logout
POST /auth/reset-password
GET  /auth/validate-token
```

#### Student Data Endpoints:
```
GET  /student/profile/{enrollmentNumber}
GET  /student/attendance/{enrollmentNumber}
GET  /student/assignments/{enrollmentNumber}
GET  /student/notices
GET  /student/registration-status/{enrollmentNumber}
```

#### QR Verification:
```
GET  /verify/{enrollmentNumber}
```

### 🔄 Mock Data System
- **Development Ready**: Complete mock data for all features
- **Easy Migration**: Simple switch from mock to real API calls
- **Structured Format**: JSON-compatible data structures
- **Error Handling**: Comprehensive error management

---

## 🎨 Design System

### 🎨 Color Scheme
- **Primary**: Red (`#FF0000`) - University brand color
- **Background**: White (`#FFFFFF`)
- **Text**: Black (`#000000`) for primary text
- **Secondary**: Gray variants for supporting text
- **Accent**: Red opacity variants for highlights

### 📱 UI Components
- **Custom Tab Bar**: Bottom navigation with red accents
- **Card Layouts**: Elevated cards with shadows and borders
- **Form Elements**: Custom text fields and secure fields
- **Animations**: Spring animations for smooth interactions
- **Typography**: Hierarchical text styling

### 🔄 Animations & Interactions
- **Typewriter Effect**: Character-by-character text animation
- **Card Flip**: 3D rotation for ID card front/back
- **Keyboard Handling**: Smart view adjustment
- **Tab Transitions**: Smooth navigation between sections
- **Loading States**: Progress indicators during API calls

---

## 🚀 Future Expansion Plans

### 📚 Student Features (Planned)
- **Attendance Tracking**: Real-time attendance monitoring
- **Assignment Management**: Submit and track assignments
- **Grade Viewing**: Semester and overall grade reports
- **Fee Management**: Payment history and pending fees
- **Library Integration**: Book reservations and renewals
- **Hostel Management**: Room allocation and maintenance
- **Event Registration**: Campus event participation
- **Timetable View**: Class schedules and room information

### 👨‍🏫 Faculty Features (Planned)
- **Class Management**: Course and student management
- **Attendance Marking**: Digital attendance system
- **Grade Entry**: Assignment and exam grade submission
- **Student Analytics**: Performance tracking and reports
- **Resource Sharing**: Course materials and announcements

### 👨‍💼 Admin Features (Planned)
- **User Management**: Student and faculty administration
- **Course Management**: Curriculum and schedule management
- **Report Generation**: Institutional analytics and reports
- **System Configuration**: Platform settings and permissions
- **Notification Management**: University-wide announcements

### 🔧 Technical Enhancements (Planned)
- **Push Notifications**: Real-time updates and alerts
- **Offline Support**: Core functionality without internet
- **Biometric Login**: Face ID and Touch ID integration
- **Multi-language Support**: Hindi and English interfaces
- **Dark Mode**: Theme switching capability
- **iPad Optimization**: Enhanced layouts for larger screens

---

## 🔒 Security Features

### 🛡️ Implemented Security
- **Keychain Storage**: Secure token management
- **Input Validation**: Form validation and sanitization
- **Secure Fields**: Password protection with visibility toggle
- **Session Management**: Automatic logout and token refresh

### 🔐 Planned Security Enhancements
- **JWT Token Validation**: Server-side token verification
- **Biometric Authentication**: Face ID/Touch ID integration
- **API Encryption**: HTTPS and certificate pinning
- **Data Encryption**: Local data protection
- **Audit Logging**: Security event tracking

---

## 📱 QR Code Implementation

### ✅ Current Features
- **Real QR Generation**: Using Core Image CIFilter
- **Structured Data**: JSON format with complete student info
- **High Quality**: Error correction level "H" for reliability
- **Scalable Design**: Crisp QR codes at any size

### 🔄 QR Code Use Cases
1. **Student Verification**: Campus security and access control
2. **Library Access**: Automated book checkout/return
3. **Exam Verification**: Identity confirmation in exam halls
4. **Event Check-in**: Quick registration for campus events
5. **Hostel Access**: Room entry and visitor management
6. **Attendance Marking**: Faculty can scan for attendance

### 📊 QR Data Format
The QR code contains structured JSON with:
- Student identification details
- Academic information
- Validity period
- Verification URL for backend validation
- Issue timestamp for audit trails

---

## 🧪 Testing & Quality Assurance

### ✅ Current Testing Setup
- **Unit Tests**: Basic test structure in place
- **UI Tests**: User interface testing framework
- **Manual Testing**: Comprehensive feature validation

### 🔍 Testing Areas Covered
- **Authentication Flow**: Login/logout functionality
- **Navigation**: Tab switching and view transitions
- **Form Validation**: Input field validation
- **QR Generation**: QR code creation and data integrity
- **Keyboard Handling**: UI responsiveness
- **Animation Performance**: Smooth user interactions

---

## 📦 Installation & Setup

### 📋 Prerequisites
- **Xcode**: Version 15.0 or later
- **iOS**: Target deployment iOS 15.0+
- **Swift**: Version 5.5 or later

### 🚀 Getting Started
1. **Clone Repository**:
   ```bash
   git clone [repository-url]
   cd MyGBU
   ```

2. **Open in Xcode**:
   ```bash
   open MyGBU.xcodeproj
   ```

3. **Run Application**:
   - Select target device/simulator
   - Press `Cmd + R` to build and run

4. **Test Login**:
   - Use demo credentials provided above
   - Explore all implemented features

---

## 🔄 API Integration Guide

### 🔌 Replacing Mock Data

#### 1. Update Base URL:
```swift
// In AuthenticationService.swift
private let baseURL = "https://your-api-domain.com/api/v1"
```

#### 2. Replace Mock Functions:
```swift
// Replace simulateLogin() with actual API call
private func performAPILogin(request: LoginRequest) {
    // Implement actual URLSession API call
}
```

#### 3. Update Data Models:
- Models are already Codable-ready
- Add any additional fields required by your API
- Update mock data creation functions

#### 4. Error Handling:
- Implement proper error responses
- Add network connectivity checks
- Handle API rate limiting

---

## 🤝 Contributing

### 📝 Development Guidelines
- **Code Style**: Follow Swift API Design Guidelines
- **Architecture**: Maintain MVVM pattern
- **Testing**: Write tests for new features
- **Documentation**: Update README for new features

### 🔄 Feature Development Process
1. **Create Feature Branch**: `feature/feature-name`
2. **Implement Feature**: Following existing patterns
3. **Add Tests**: Unit and UI tests as needed
4. **Update Documentation**: README and code comments
5. **Submit Pull Request**: For code review

---

## 📞 Support & Contact

### 🎓 University Information
- **Institution**: Gautam Buddha University
- **Website**: https://gbu.ac.in
- **Location**: Greater Noida, Uttar Pradesh, India

### 👨‍💻 Development Team
- **Project Type**: University ERP Platform
- **Platform**: iOS (SwiftUI)
- **Architecture**: MVVM with Combine

---

## 📄 License

This project is developed for Gautam Buddha University's internal use. All rights reserved.

---

## 🔄 Version History

### Version 1.0.0 (Current)
- ✅ Complete authentication system
- ✅ Student dashboard with home tab
- ✅ Virtual E-ID card with QR code
- ✅ Professional UI/UX design
- ✅ Database-ready architecture
- ✅ Mock data system for development

### Planned Versions
- **v1.1.0**: Complete student features (attendance, assignments)
- **v1.2.0**: Faculty dashboard and features
- **v1.3.0**: Admin panel and management tools
- **v2.0.0**: Full API integration and production deployment

---

**Built with ❤️ for Gautam Buddha University**

*This README provides comprehensive documentation of the MyGBU ERP platform. For technical questions or feature requests, please refer to the development guidelines above.*