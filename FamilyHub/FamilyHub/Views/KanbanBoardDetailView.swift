import SwiftUI
import UniformTypeIdentifiers

struct KanbanBoardDetailView: View {
    let board: KanbanBoard
    @ObservedObject var kanbanViewModel: KanbanViewModel
    @State private var showingAddTask = false
    @State private var selectedColumnIndex = 0
    @State private var showingBoardSettings = false
    @State private var showingEditTask = false
    @State private var selectedTask: KanbanTask?
    @State private var showingAddColumn = false
    @State private var newColumnName = ""

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
                            selectedTask = task
                            selectedColumnIndex = columnIndex
                            showingEditTask = true
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
        .sheet(isPresented: $showingEditTask) {
            if let task = selectedTask {
                EditTaskView(
                    kanbanViewModel: kanbanViewModel,
                    boardId: board.id,
                    columnIndex: selectedColumnIndex,
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
    @State private var draggedTask: KanbanTask?

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
                VStack(spacing: 10) {
                    ForEach(column.tasks) { task in
                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .font(.caption)

                            KanbanTaskCardView(task: task)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTaskTapped(task)
                        }
                        .onDrag {
                            self.draggedTask = task
                            return NSItemProvider(object: "\(boardId)|\(columnIndex)|\(task.id)" as NSString)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let task = column.tasks[index]
                            kanbanViewModel.deleteTask(boardId: boardId, columnIndex: columnIndex, taskId: task.id)
                        }
                    }
                    .onInsert(of: [.text]) { index, providers in
                        handleDrop(at: index, providers: providers)
                    }

                    // Drop zone at the end of column
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 50)
                        .onDrop(of: [.text], delegate: ColumnDropDelegate(
                            boardId: boardId,
                            targetColumnIndex: columnIndex,
                            kanbanViewModel: kanbanViewModel
                        ))

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

    private func handleDrop(at index: Int, providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }

        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, error) in
            guard let data = item as? Data,
                  let dragInfo = String(data: data, encoding: .utf8) else {
                return
            }

            let components = dragInfo.components(separatedBy: "|")
            guard components.count == 3,
                  let fromColumnIndex = Int(components[1]) else {
                return
            }

            let sourceBoardId = components[0]
            let taskId = components[2]

            DispatchQueue.main.async {
                // Moving between columns
                if fromColumnIndex != columnIndex {
                    kanbanViewModel.moveTask(
                        boardId: sourceBoardId,
                        fromColumn: fromColumnIndex,
                        toColumn: columnIndex,
                        taskId: taskId
                    )
                }
                // TODO: Handle reordering within same column
            }
        }
    }
}

// Drop delegate for dropping tasks into columns
struct ColumnDropDelegate: DropDelegate {
    let boardId: String
    let targetColumnIndex: Int
    let kanbanViewModel: KanbanViewModel

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }

        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, error) in
            guard let data = item as? Data,
                  let dragInfo = String(data: data, encoding: .utf8) else {
                return
            }

            let components = dragInfo.components(separatedBy: "|")
            guard components.count == 3,
                  let fromColumnIndex = Int(components[1]) else {
                return
            }

            let sourceBoardId = components[0]
            let taskId = components[2]

            // Only move if dropping in a different column
            if fromColumnIndex != targetColumnIndex {
                DispatchQueue.main.async {
                    kanbanViewModel.moveTask(
                        boardId: sourceBoardId,
                        fromColumn: fromColumnIndex,
                        toColumn: targetColumnIndex,
                        taskId: taskId
                    )
                }
            }
        }
        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }

    func dropEntered(info: DropInfo) {
        // Optional: Add visual feedback when hovering over column
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
