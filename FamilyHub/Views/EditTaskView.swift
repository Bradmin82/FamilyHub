import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kanbanViewModel: KanbanViewModel
    let boardId: String
    let columnIndex: Int
    let task: KanbanTask

    @State private var taskTitle: String
    @State private var taskDescription: String
    @State private var selectedPriority: KanbanTask.Priority
    @State private var showingDeleteConfirmation = false

    init(kanbanViewModel: KanbanViewModel, boardId: String, columnIndex: Int, task: KanbanTask) {
        self.kanbanViewModel = kanbanViewModel
        self.boardId = boardId
        self.columnIndex = columnIndex
        self.task = task
        _taskTitle = State(initialValue: task.title)
        _taskDescription = State(initialValue: task.description)
        _selectedPriority = State(initialValue: task.priority)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                }

                Section(header: Text("Description")) {
                    RichTextEditor(text: $taskDescription)
                        .frame(minHeight: 200)
                }

                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        Text("Low").tag(KanbanTask.Priority.low)
                        Text("Medium").tag(KanbanTask.Priority.medium)
                        Text("High").tag(KanbanTask.Priority.high)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button(action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
            .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTask()
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
        }
    }

    private func saveTask() {
        var updatedTask = task
        updatedTask.title = taskTitle
        updatedTask.description = taskDescription
        updatedTask.priority = selectedPriority

        kanbanViewModel.updateTask(boardId: boardId, columnIndex: columnIndex, task: updatedTask)
        dismiss()
    }

    private func deleteTask() {
        kanbanViewModel.deleteTask(boardId: boardId, columnIndex: columnIndex, taskId: task.id)
        dismiss()
    }
}
