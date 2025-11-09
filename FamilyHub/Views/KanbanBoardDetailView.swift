import SwiftUI

struct KanbanBoardDetailView: View {
    let board: KanbanBoard
    @ObservedObject var kanbanViewModel: KanbanViewModel
    @State private var showingAddTask = false
    @State private var selectedColumnIndex = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 15) {
                ForEach(board.columns.indices, id: \.self) { columnIndex in
                    KanbanColumnView(
                        column: board.columns[columnIndex],
                        boardId: board.id,
                        columnIndex: columnIndex,
                        kanbanViewModel: kanbanViewModel,
                        onAddTask: {
                            selectedColumnIndex = columnIndex
                            showingAddTask = true
                        }
                    )
                }
            }
            .padding()
        }
        .navigationTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddTask) {
            CreateTaskView(
                kanbanViewModel: kanbanViewModel,
                boardId: board.id,
                columnIndex: selectedColumnIndex
            )
        }
    }
}

struct KanbanColumnView: View {
    let column: KanbanColumn
    let boardId: String
    let columnIndex: Int
    @ObservedObject var kanbanViewModel: KanbanViewModel
    let onAddTask: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(column.name)
                    .font(.headline)
                Spacer()
                Text("\(column.tasks.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(column.tasks) { task in
                        KanbanTaskCardView(task: task)
                    }

                    Button(action: onAddTask) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Task")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 300)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct KanbanTaskCardView: View {
    let task: KanbanTask

    var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
                Text(task.priority.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(priorityColor)
                Spacer()
            }

            Text(task.title)
                .font(.headline)

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }

            Text(task.createdDate, style: .date)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CreateTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kanbanViewModel: KanbanViewModel
    let boardId: String
    let columnIndex: Int

    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedPriority: KanbanTask.Priority = .medium

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                    TextField("Description", text: $taskDescription)
                }

                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        Text("Low").tag(KanbanTask.Priority.low)
                        Text("Medium").tag(KanbanTask.Priority.medium)
                        Text("High").tag(KanbanTask.Priority.high)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        createTask()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }

    private func createTask() {
        let task = KanbanTask(title: taskTitle, description: taskDescription, priority: selectedPriority)
        kanbanViewModel.addTask(boardId: boardId, columnIndex: columnIndex, task: task)
        dismiss()
    }
}
