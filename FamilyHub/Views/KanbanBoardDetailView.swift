import SwiftUI
import UniformTypeIdentifiers

struct KanbanBoardDetailView: View {
    let board: KanbanBoard
    @ObservedObject var kanbanViewModel: KanbanViewModel
    @State private var showingAddTask = false
    @State private var selectedColumnIndex = 0
    @State private var showingBoardSettings = false
    @State private var editingTaskId: String?
    @State private var editingColumnIndex: Int?
    @State private var showingAddColumn = false
    @State private var newColumnName = ""

    var showingEditTask: Binding<Bool> {
        Binding(
            get: { editingTaskId != nil },
            set: { if !$0 { editingTaskId = nil; editingColumnIndex = nil } }
        )
    }

    func findTask(taskId: String, columnIndex: Int) -> KanbanTask? {
        guard columnIndex < board.columns.count else { return nil }
        return board.columns[columnIndex].tasks.first(where: { $0.id == taskId })
    }

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
                        },
                        onTaskTapped: { task in
                            editingTaskId = task.id
                            editingColumnIndex = columnIndex
                        }
                    )
                }

                // Add Column Button
                Button(action: { showingAddColumn = true }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                        Text("Add Column")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 100)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingBoardSettings = true }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            CreateTaskView(
                kanbanViewModel: kanbanViewModel,
                boardId: board.id,
                columnIndex: selectedColumnIndex
            )
        }
        .sheet(isPresented: showingEditTask) {
            if let taskId = editingTaskId,
               let columnIndex = editingColumnIndex,
               let task = findTask(taskId: taskId, columnIndex: columnIndex) {
                EditTaskView(
                    kanbanViewModel: kanbanViewModel,
                    boardId: board.id,
                    columnIndex: columnIndex,
                    task: task
                )
            }
        }
        .sheet(isPresented: $showingBoardSettings) {
            BoardSettingsView(
                kanbanViewModel: kanbanViewModel,
                board: board
            )
        }
        .alert("Add Column", isPresented: $showingAddColumn) {
            TextField("Column Name", text: $newColumnName)
            Button("Cancel", role: .cancel) {
                newColumnName = ""
            }
            Button("Add") {
                if !newColumnName.isEmpty {
                    kanbanViewModel.addColumn(boardId: board.id, columnName: newColumnName)
                    newColumnName = ""
                }
            }
        } message: {
            Text("Enter a name for the new column")
        }
    }
}

struct KanbanColumnView: View {
    let column: KanbanColumn
    let boardId: String
    let columnIndex: Int
    @ObservedObject var kanbanViewModel: KanbanViewModel
    let onAddTask: () -> Void
    let onTaskTapped: (KanbanTask) -> Void

    @State private var showingColumnMenu = false
    @State private var showingRenameAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var newColumnName = ""
    @State private var draggedOverIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(column.name)
                    .font(.headline)
                Spacer()
                Text("\(column.tasks.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Button(action: { showingColumnMenu = true }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .confirmationDialog("Column Options", isPresented: $showingColumnMenu) {
                Button("Rename") {
                    newColumnName = column.name
                    showingRenameAlert = true
                }
                Button("Delete", role: .destructive) {
                    showingDeleteConfirmation = true
                }
                Button("Cancel", role: .cancel) { }
            }

            ScrollView {
                VStack(spacing: 4) {
                    // Drop zone at the top
                    DropZoneView(isHighlighted: draggedOverIndex == 0)
                        .onDrop(of: [UTType.plainText], delegate: TaskDropDelegate(
                            boardId: boardId,
                            targetColumnIndex: columnIndex,
                            targetTaskIndex: 0,
                            kanbanViewModel: kanbanViewModel,
                            onDragOver: { draggedOverIndex = 0 },
                            onDragExit: { draggedOverIndex = nil }
                        ))

                    ForEach(Array(column.tasks.enumerated()), id: \.element.id) { index, task in
                        VStack(spacing: 4) {
                            KanbanTaskCardView(task: task)
                                .onTapGesture {
                                    onTaskTapped(task)
                                }
                                .draggable("\(boardId)|\(columnIndex)|\(task.id)") {
                                    // Preview while dragging
                                    VStack {
                                        Text(task.title)
                                            .font(.headline)
                                            .padding()
                                            .background(Color(.systemBackground))
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    }
                                }

                            // Drop zone after each task
                            DropZoneView(isHighlighted: draggedOverIndex == index + 1)
                                .onDrop(of: [UTType.plainText], delegate: TaskDropDelegate(
                                    boardId: boardId,
                                    targetColumnIndex: columnIndex,
                                    targetTaskIndex: index + 1,
                                    kanbanViewModel: kanbanViewModel,
                                    onDragOver: { draggedOverIndex = index + 1 },
                                    onDragExit: { draggedOverIndex = nil }
                                ))
                        }
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
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 300)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .alert("Rename Column", isPresented: $showingRenameAlert) {
            TextField("Column Name", text: $newColumnName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newColumnName.isEmpty {
                    kanbanViewModel.renameColumn(boardId: boardId, columnIndex: columnIndex, newName: newColumnName)
                }
            }
        } message: {
            Text("Enter a new name for this column")
        }
        .alert("Delete Column", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                kanbanViewModel.deleteColumn(boardId: boardId, columnIndex: columnIndex)
            }
        } message: {
            Text("Are you sure you want to delete this column? All tasks in it will be lost.")
        }
    }
}

// Drop zone indicator
struct DropZoneView: View {
    let isHighlighted: Bool

    var body: some View {
        Rectangle()
            .fill(isHighlighted ? Color.blue.opacity(0.4) : Color.gray.opacity(0.1))
            .frame(height: 30)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(isHighlighted ? Color.blue : Color.gray.opacity(0.3))
            )
    }
}

// Drop delegate for dropping tasks at specific positions
struct TaskDropDelegate: DropDelegate {
    let boardId: String
    let targetColumnIndex: Int
    let targetTaskIndex: Int
    let kanbanViewModel: KanbanViewModel
    let onDragOver: () -> Void
    let onDragExit: () -> Void

    func performDrop(info: DropInfo) -> Bool {
        print("🎯 Attempting to perform drop at column \(targetColumnIndex), index \(targetTaskIndex)")

        guard let itemProvider = info.itemProviders(for: [UTType.plainText]).first else {
            print("❌ No item provider found for plainText")
            onDragExit()
            return false
        }

        _ = itemProvider.loadObject(ofClass: String.self) { (dragInfo, error) in
            if let error = error {
                print("❌ Error loading data: \(error)")
                DispatchQueue.main.async { self.onDragExit() }
                return
            }

            guard let dragInfo = dragInfo else {
                print("❌ Could not decode drag data")
                DispatchQueue.main.async { self.onDragExit() }
                return
            }

            print("📦 Drag data received: \(dragInfo)")

            let components = dragInfo.components(separatedBy: "|")
            guard components.count == 3,
                  let fromColumnIndex = Int(components[1]) else {
                print("❌ Invalid drag data format: expected 3 components, got \(components.count)")
                DispatchQueue.main.async { self.onDragExit() }
                return
            }

            let sourceBoardId = components[0]
            let taskId = components[2]

            print("✅ Moving task \(taskId) from column \(fromColumnIndex) to column \(targetColumnIndex) at index \(targetTaskIndex)")

            DispatchQueue.main.async {
                self.kanbanViewModel.moveTask(
                    boardId: sourceBoardId,
                    fromColumn: fromColumnIndex,
                    toColumn: targetColumnIndex,
                    taskId: taskId,
                    toIndex: targetTaskIndex
                )
                self.onDragExit()
            }
        }
        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        let canDrop = info.hasItemsConforming(to: [UTType.plainText])
        print("🔍 Validating drop at column \(targetColumnIndex), index \(targetTaskIndex): \(canDrop)")
        return canDrop
    }

    func dropEntered(info: DropInfo) {
        print("👆 Drop entered at column \(targetColumnIndex), index \(targetTaskIndex)")
        onDragOver()
    }

    func dropExited(info: DropInfo) {
        print("👋 Drop exited")
        onDragExit()
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
                .lineLimit(2)

            if !task.description.isEmpty {
                Text(parseMarkdown(task.description))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(4)
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

    private func parseMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)

        // Remove markdown symbols for preview (bold **)
        let cleanText = text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "[ ] ", with: "☐ ")
            .replacingOccurrences(of: "[x] ", with: "☑ ")

        return AttributedString(cleanText)
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
