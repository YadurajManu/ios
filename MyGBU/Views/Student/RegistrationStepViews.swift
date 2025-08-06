import SwiftUI

// MARK: - Course Selection View
struct CourseSelectionView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    @State private var selectedCourseType: String = "all"
    @State private var searchText = ""
    
    var filteredCourses: [Course] {
        let courses = registrationViewModel.availableCourses
        
        let typeFiltered = selectedCourseType == "all" ? courses : courses.filter { $0.courseType.rawValue == selectedCourseType }
        
        if searchText.isEmpty {
            return typeFiltered
        } else {
            return typeFiltered.filter { course in
                let nameMatch = course.courseName.localizedCaseInsensitiveContains(searchText)
                let codeMatch = course.courseCode.localizedCaseInsensitiveContains(searchText)
                return nameMatch || codeMatch
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Select Courses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Choose courses from \(registrationViewModel.formData.selectedSchool?.schoolName ?? "selected school")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Search and Filter
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search courses...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // Course Type Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedCourseType == "all"
                        ) {
                            selectedCourseType = "all"
                        }
                        
                        let courseTypes = Array(Set(registrationViewModel.availableCourses.map { $0.courseType.rawValue }))
                        ForEach(courseTypes, id: \.self) { type in
                            FilterChip(
                                title: registrationViewModel.getCourseTypeDisplayName(type),
                                isSelected: selectedCourseType == type
                            ) {
                                selectedCourseType = type
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Course List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredCourses) { course in
                        CourseCard(
                            course: course,
                            isSelected: registrationViewModel.isCourseSelected(course),
                            onToggle: {
                                registrationViewModel.toggleCourseSelection(course)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Summary
            if !registrationViewModel.formData.selectedCourses.isEmpty {
                VStack(spacing: 8) {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Courses: \(registrationViewModel.formData.selectedCourses.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Total Credits: \(String(format: "%.1f", registrationViewModel.formData.totalCredits))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("View Summary") {
                            // This could show a detailed summary
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.05))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Form Completion View
struct FormCompletionView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Complete Registration")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Fill in the remaining details for your registration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 20) {
                    // Registration Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Registration Type")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Registration Type", selection: $registrationViewModel.formData.registrationType) {
                            ForEach(RegistrationType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Academic Year
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Academic Year")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("e.g., 2024-25", text: $registrationViewModel.formData.academicYear)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Additional Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Notes (Optional)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $registrationViewModel.formData.additionalNotes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                
                // Validation Errors
                if !registrationViewModel.validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Please fix the following issues:")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        ForEach(registrationViewModel.validationErrors, id: \.self) { error in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Review View
struct ReviewView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Review Registration")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Please review your registration details before submitting")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // School Information
                if let school = registrationViewModel.formData.selectedSchool {
                    ReviewSection(title: "Selected School", icon: "building.2") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(school.schoolName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Code: \(school.schoolCode)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(school.schoolType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Selected Courses
                ReviewSection(title: "Selected Courses", icon: "book") {
                    VStack(spacing: 12) {
                        ForEach(registrationViewModel.formData.selectedCourses) { course in
                            CourseReviewCard(course: course)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Credits")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", registrationViewModel.formData.totalCredits))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Registration Details
                ReviewSection(title: "Registration Details", icon: "doc.text") {
                    VStack(spacing: 12) {
                        ReviewRow(title: "Registration Type", value: registrationViewModel.formData.registrationType.displayName)
                        ReviewRow(title: "Academic Year", value: registrationViewModel.formData.academicYear)
                        
                        if !registrationViewModel.formData.additionalNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Additional Notes")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(registrationViewModel.formData.additionalNotes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Confirmation View
struct ConfirmationView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            
            // Success Message
            VStack(spacing: 12) {
                Text("Registration Successful!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your course registration has been submitted successfully. You will receive a confirmation email shortly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Registration Summary
            VStack(spacing: 16) {
                Text("Registration Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    SummaryRow(title: "School", value: registrationViewModel.formData.selectedSchool?.schoolName ?? "")
                    SummaryRow(title: "Courses", value: "\(registrationViewModel.formData.selectedCourses.count)")
                    SummaryRow(title: "Total Credits", value: String(format: "%.1f", registrationViewModel.formData.totalCredits))
                    SummaryRow(title: "Academic Year", value: registrationViewModel.formData.academicYear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Supporting Components

struct CourseCard: View {
    let course: Course
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.red : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Course Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.courseName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(course.courseCode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Course Type Badge
                VStack(spacing: 4) {
                    Text("\(course.totalCredits) Credits")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                    
                    Text(course.courseType.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isSelected ? .red.opacity(0.2) : .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.red : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReviewSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .font(.headline)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding(.horizontal, 20)
    }
}

struct CourseReviewCard: View {
    let course: Course
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(course.courseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(course.courseCode)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(course.totalCredits) Credits")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
        }
        .padding(.vertical, 8)
    }
}

struct ReviewRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
} 