import SwiftUI

struct StudentSkillsView: View {
    let skills: [Skill]
    @State private var selectedCategory: Skill.SkillCategory? = nil
    @State private var sortBy: SkillSortOption = .proficiency
    @State private var showingAddSkill = false
    @State private var showingEditSkill = false
    @State private var selectedSkill: Skill? = nil
    @State private var showingDeleteConfirmation = false
    @State private var skillToDelete: Skill? = nil
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    enum SkillSortOption: String, CaseIterable {
        case proficiency = "Proficiency"
        case category = "Category"
        case endorsements = "Endorsements"
        case recent = "Recently Updated"
        
        var displayName: String { rawValue }
    }
    
    var filteredAndSortedSkills: [Skill] {
        var filteredSkills = skills
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            filteredSkills = filteredSkills.filter { $0.category == selectedCategory }
        }
        
        // Sort by selected option
        switch sortBy {
        case .proficiency:
            filteredSkills.sort { $0.proficiencyLevel.progressValue > $1.proficiencyLevel.progressValue }
        case .category:
            filteredSkills.sort { $0.category.displayName < $1.category.displayName }
        case .endorsements:
            filteredSkills.sort { $0.endorsements > $1.endorsements }
        case .recent:
            filteredSkills.sort { $0.lastUpdated > $1.lastUpdated }
        }
        
        return filteredSkills
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Controls
                headerControlsSection
                
                // Skills Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredAndSortedSkills.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(filteredAndSortedSkills) { skill in
                                ModernSkillCard(
                                    skill: skill,
                                    onEdit: { editSkill(skill) },
                                    onDelete: { deleteSkill(skill) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 100) // Tab bar space
                }
            }
            .navigationTitle("Skills & Strengths")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSkill = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddSkill) {
            AddEditSkillView(mode: .add)
                .environmentObject(dashboardViewModel)
        }
        .sheet(isPresented: $showingEditSkill) {
            if let skill = selectedSkill {
                AddEditSkillView(mode: .edit(skill))
                    .environmentObject(dashboardViewModel)
            }
        }
        .alert("Delete Skill", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let skill = skillToDelete {
                    confirmDeleteSkill(skill)
                }
            }
        } message: {
            Text("Are you sure you want to delete this skill? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Controls Section
    private var headerControlsSection: some View {
        VStack(spacing: 16) {
            // Stats Overview
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Skills",
                    value: "\(skills.count)",
                    color: .blue
                )
                
                StatCard(
                    title: "Categories",
                    value: "\(Set(skills.map { $0.category }).count)",
                    color: .green
                )
                
                StatCard(
                    title: "Verified",
                    value: "\(skills.filter { $0.isVerified }.count)",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ModernFilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(Skill.SkillCategory.allCases, id: \.self) { category in
                        ModernFilterChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Sort Control
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(SkillSortOption.allCases, id: \.self) { option in
                        Button(option.displayName) {
                            sortBy = option
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(sortBy.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.1))
                    )
                }
                
                Spacer()
                
                Text("\(filteredAndSortedSkills.count) skills")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Skills Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add your skills to showcase your strengths and abilities")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddSkill = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Your First Skill")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
            }
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    private func editSkill(_ skill: Skill) {
        selectedSkill = skill
        showingEditSkill = true
    }
    
    private func deleteSkill(_ skill: Skill) {
        skillToDelete = skill
        showingDeleteConfirmation = true
    }
    
    private func confirmDeleteSkill(_ skill: Skill) {
        // TODO: Implement API call to delete skill
        // StudentAPIService.shared.deleteSkill(skillId: skill.id)
        print("Deleting skill: \(skill.skillName)")
    }
}

// MARK: - Modern Skill Card
struct ModernSkillCard: View {
    let skill: Skill
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showingActions = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with actions
            HStack(alignment: .top) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(skill.category.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: skill.category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(skill.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(skill.skillName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if skill.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(skill.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(skill.category.color.opacity(0.1))
                        )
                }
                
                Spacer()
                
                // Actions Menu
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            
            // Proficiency Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Proficiency Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(skill.proficiencyLevel.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(skill.proficiencyLevel.color)
                }
                
                // Proficiency Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        skill.proficiencyLevel.color.opacity(0.7),
                                        skill.proficiencyLevel.color
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * skill.proficiencyLevel.progressValue, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Stats Row
            HStack(spacing: 24) {
                SkillStatItem(
                    icon: "hand.thumbsup.fill",
                    value: "\(skill.endorsements)",
                    label: "Endorsements",
                    color: .orange
                )
                
                SkillStatItem(
                    icon: "clock.fill",
                    value: formatDate(skill.lastUpdated),
                    label: "Updated",
                    color: .blue
                )
                
                if let certifications = skill.certifications, !certifications.isEmpty {
                    SkillStatItem(
                        icon: "rosette",
                        value: "\(certifications.count)",
                        label: "Certificates",
                        color: .green
                    )
                }
                
                Spacer()
            }
            
            // Certifications (if any)
            if let certifications = skill.certifications, !certifications.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Certifications")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 6) {
                        ForEach(certifications.prefix(2), id: \.self) { certification in
                            HStack {
                                Image(systemName: "rosette")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(certification)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                        }
                        
                        if certifications.count > 2 {
                            Text("+ \(certifications.count - 2) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct SkillStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ModernFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.red : Color(.systemGray6))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: - Add/Edit Skill View
struct AddEditSkillView: View {
    enum Mode {
        case add
        case edit(Skill)
        
        var title: String {
            switch self {
            case .add: return "Add Skill"
            case .edit: return "Edit Skill"
            }
        }
    }
    
    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    @State private var skillName = ""
    @State private var selectedCategory: Skill.SkillCategory = .technical
    @State private var selectedProficiency: Skill.ProficiencyLevel = .beginner
    @State private var certifications: [String] = []
    @State private var newCertification = ""
    @State private var isVerified = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Skill Information") {
                    TextField("Skill Name", text: $skillName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Skill.SkillCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    Picker("Proficiency Level", selection: $selectedProficiency) {
                        ForEach(Skill.ProficiencyLevel.allCases, id: \.self) { level in
                            Text(level.displayName)
                                .tag(level)
                        }
                    }
                }
                
                Section("Certifications") {
                    ForEach(certifications.indices, id: \.self) { index in
                        HStack {
                            Text(certifications[index])
                            Spacer()
                            Button("Remove") {
                                certifications.remove(at: index)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        TextField("Add certification", text: $newCertification)
                        Button("Add") {
                            if !newCertification.isEmpty {
                                certifications.append(newCertification)
                                newCertification = ""
                            }
                        }
                        .disabled(newCertification.isEmpty)
                    }
                }
                
                Section("Verification") {
                    Toggle("Verified Skill", isOn: $isVerified)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSkill()
                    }
                    .disabled(skillName.isEmpty || isSaving)
                }
            }
        }
        .onAppear {
            setupForMode()
        }
    }
    
    private func setupForMode() {
        switch mode {
        case .add:
            break // Use default values
        case .edit(let skill):
            skillName = skill.skillName
            selectedCategory = skill.category
            selectedProficiency = skill.proficiencyLevel
            certifications = skill.certifications ?? []
            isVerified = skill.isVerified
        }
    }
    
    private func saveSkill() {
        isSaving = true
        
        let skill = Skill(
            id: UUID().uuidString,
            skillName: skillName,
            category: selectedCategory,
            proficiencyLevel: selectedProficiency,
            certifications: certifications.isEmpty ? nil : certifications,
            lastUpdated: Date(),
            endorsements: 0,
            isVerified: isVerified
        )
        
        // TODO: Implement API call
        switch mode {
        case .add:
            // StudentAPIService.shared.addSkill(skill)
            print("Adding skill: \(skill.skillName)")
        case .edit(let originalSkill):
            // StudentAPIService.shared.updateSkill(skillId: originalSkill.id, skill: skill)
            print("Updating skill: \(skill.skillName)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    StudentSkillsView(skills: [])
        .environmentObject(StudentDashboardViewModel())
} 