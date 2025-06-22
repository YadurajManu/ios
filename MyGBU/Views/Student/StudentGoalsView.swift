import SwiftUI

struct StudentGoalsView: View {
    let goals: [AcademicGoal]
    @State private var selectedStatus: AcademicGoal.GoalStatus? = nil
    @State private var selectedType: AcademicGoal.GoalType? = nil
    @State private var sortBy: GoalSortOption = .priority
    @State private var showingAddGoal = false
    @State private var showingEditGoal = false
    @State private var selectedGoal: AcademicGoal? = nil
    @State private var showingDeleteConfirmation = false
    @State private var goalToDelete: AcademicGoal? = nil
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    enum GoalSortOption: String, CaseIterable {
        case priority = "Priority"
        case progress = "Progress"
        case deadline = "Deadline"
        case recent = "Recently Updated"
        
        var displayName: String { rawValue }
    }
    
    var filteredAndSortedGoals: [AcademicGoal] {
        var filteredGoals = goals
        
        // Filter by status
        if let selectedStatus = selectedStatus {
            filteredGoals = filteredGoals.filter { $0.status == selectedStatus }
        }
        
        // Filter by type
        if let selectedType = selectedType {
            filteredGoals = filteredGoals.filter { $0.type == selectedType }
        }
        
        // Sort by selected option
        switch sortBy {
        case .priority:
            filteredGoals.sort { 
                $0.priority.sortOrder < $1.priority.sortOrder
            }
        case .progress:
            filteredGoals.sort { $0.progress > $1.progress }
        case .deadline:
            filteredGoals.sort { $0.targetDate < $1.targetDate }
        case .recent:
            filteredGoals.sort { $0.createdDate > $1.createdDate }
        }
        
        return filteredGoals
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Controls
                headerControlsSection
                
                // Goals Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredAndSortedGoals.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(filteredAndSortedGoals) { goal in
                                ModernGoalCard(
                                    goal: goal,
                                    onEdit: { editGoal(goal) },
                                    onDelete: { deleteGoal(goal) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 100) // Tab bar space
                }
            }
            .navigationTitle("Academic Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddGoal) {
            AddEditGoalView(mode: .add)
                .environmentObject(dashboardViewModel)
        }
        .sheet(isPresented: $showingEditGoal) {
            if let goal = selectedGoal {
                AddEditGoalView(mode: .edit(goal))
                    .environmentObject(dashboardViewModel)
            }
        }
        .alert("Delete Goal", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let goal = goalToDelete {
                    confirmDeleteGoal(goal)
                }
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Controls Section
    private var headerControlsSection: some View {
        VStack(spacing: 16) {
            // Stats Overview
            HStack(spacing: 16) {
                GoalStatCard(
                    title: "Total Goals",
                    value: "\(goals.count)",
                    color: .blue
                )
                
                GoalStatCard(
                    title: "Active",
                    value: "\(goals.filter { $0.status == .active }.count)",
                    color: .green
                )
                
                GoalStatCard(
                    title: "Completed",
                    value: "\(goals.filter { $0.status == .completed }.count)",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            
            // Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ModernGoalFilterChip(
                        title: "All Types",
                        isSelected: selectedType == nil,
                        action: { selectedType = nil }
                    )
                    
                    ForEach(AcademicGoal.GoalType.allCases, id: \.self) { type in
                        ModernGoalFilterChip(
                            title: type.displayName,
                            isSelected: selectedType == type,
                            action: { selectedType = type }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Status Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ModernGoalFilterChip(
                        title: "All Status",
                        isSelected: selectedStatus == nil,
                        action: { selectedStatus = nil }
                    )
                    
                    ForEach(AcademicGoal.GoalStatus.allCases, id: \.self) { status in
                        ModernGoalFilterChip(
                            title: status.displayName,
                            isSelected: selectedStatus == status,
                            action: { selectedStatus = status }
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
                    ForEach(GoalSortOption.allCases, id: \.self) { option in
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
                
                Text("\(filteredAndSortedGoals.count) goals")
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
            Image(systemName: "target")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Goals Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Set academic goals to track your progress and achievements")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddGoal = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Set Your First Goal")
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
    private func editGoal(_ goal: AcademicGoal) {
        selectedGoal = goal
        showingEditGoal = true
    }
    
    private func deleteGoal(_ goal: AcademicGoal) {
        goalToDelete = goal
        showingDeleteConfirmation = true
    }
    
    private func confirmDeleteGoal(_ goal: AcademicGoal) {
        // TODO: Implement API call to delete goal
        // StudentAPIService.shared.deleteGoal(goalId: goal.id)
        print("Deleting goal: \(goal.title)")
    }
}

// MARK: - Modern Goal Card
struct ModernGoalCard: View {
    let goal: AcademicGoal
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with actions
            HStack(alignment: .top) {
                // Type Icon
                ZStack {
                    Circle()
                        .fill(goal.type.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: goal.type.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(goal.type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text(goal.type.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(goal.type.color.opacity(0.1))
                            )
                        
                        Text(goal.priority.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(goal.priority.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(goal.priority.color.opacity(0.1))
                            )
                    }
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
            
            // Description
            if !goal.description.isEmpty {
                HStack {
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    Spacer()
                }
            }
            
            // Progress Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(goal.progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(goal.status.color)
                }
                
                // Progress Bar with Status Color
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        goal.status.color.opacity(0.7),
                                        goal.status.color
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * goal.progress, height: 12)
                    }
                }
                .frame(height: 12)
            }
            
            // Stats Row
            HStack(spacing: 24) {
                GoalStatItem(
                    icon: "flag.fill",
                    value: goal.status.displayName,
                    label: "Status",
                    color: goal.status.color
                )
                
                GoalStatItem(
                    icon: "calendar",
                    value: formatDate(goal.targetDate),
                    label: "Target",
                    color: .blue
                )
                
                GoalStatItem(
                    icon: "clock.fill",
                    value: daysRemaining(),
                    label: "Remaining",
                    color: daysRemainingColor()
                )
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(goal.status.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func daysRemaining() -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0
        if days < 0 {
            return "Overdue"
        } else if days == 0 {
            return "Today"
        } else {
            return "\(days) days"
        }
    }
    
    private func daysRemainingColor() -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0
        if days < 0 {
            return .red
        } else if days <= 7 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Supporting Views
struct GoalStatCard: View {
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

struct ModernGoalFilterChip: View {
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

struct GoalStatItem: View {
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
                    .lineLimit(1)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Add/Edit Goal View
struct AddEditGoalView: View {
    enum Mode {
        case add
        case edit(AcademicGoal)
        
        var title: String {
            switch self {
            case .add: return "Add Goal"
            case .edit: return "Edit Goal"
            }
        }
    }
    
    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dashboardViewModel: StudentDashboardViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType: AcademicGoal.GoalType = .academic
    @State private var selectedPriority: AcademicGoal.Priority = .medium
    @State private var selectedStatus: AcademicGoal.GoalStatus = .active
    @State private var targetDate = Date()
    @State private var progress: Double = 0.0
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Information") {
                    TextField("Goal Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.sentences)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(AcademicGoal.GoalType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Priority & Status") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(AcademicGoal.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(AcademicGoal.GoalStatus.allCases, id: \.self) { status in
                            Text(status.displayName)
                                .tag(status)
                        }
                    }
                }
                
                Section("Timeline & Progress") {
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .fontWeight(.medium)
                        }
                        
                        Slider(value: $progress, in: 0...1, step: 0.05)
                            .accentColor(.red)
                    }
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
                        saveGoal()
                    }
                    .disabled(title.isEmpty || isSaving)
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
            targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        case .edit(let goal):
            title = goal.title
            description = goal.description
            selectedType = goal.type
            selectedPriority = goal.priority
            selectedStatus = goal.status
            targetDate = goal.targetDate
            progress = goal.progress
        }
    }
    
    private func saveGoal() {
        isSaving = true
        
        let goal = AcademicGoal(
            id: UUID().uuidString,
            type: selectedType,
            title: title,
            description: description,
            targetDate: targetDate,
            priority: selectedPriority,
            status: selectedStatus,
            progress: progress,
            createdDate: Date(),
            updatedDate: Date()
        )
        
        // TODO: Implement API call
        switch mode {
        case .add:
            // StudentAPIService.shared.addGoal(goal)
            print("Adding goal: \(goal.title)")
        case .edit(let originalGoal):
            // StudentAPIService.shared.updateGoal(goalId: originalGoal.id, goal: goal)
            print("Updating goal: \(goal.title)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Extensions for Goal Types
extension AcademicGoal.Priority {
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

#Preview {
    StudentGoalsView(goals: [])
        .environmentObject(StudentDashboardViewModel())
} 