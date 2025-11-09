import Foundation

struct KanbanBoard: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var createdBy: String
    var members: [String] // User IDs
    var columns: [KanbanColumn]
    var createdDate: Date

    init(id: String = UUID().uuidString, name: String, description: String, createdBy: String) {
        self.id = id
        self.name = name
        self.description = description
        self.createdBy = createdBy
        self.members = [createdBy]
        self.columns = [
            KanbanColumn(name: "To Do"),
            KanbanColumn(name: "In Progress"),
            KanbanColumn(name: "Done")
        ]
        self.createdDate = Date()
    }
}

struct KanbanColumn: Identifiable, Codable {
    var id: String
    var name: String
    var tasks: [KanbanTask]

    init(id: String = UUID().uuidString, name: String, tasks: [KanbanTask] = []) {
        self.id = id
        self.name = name
        self.tasks = tasks
    }
}

struct KanbanTask: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var assignedTo: String? // User ID
    var priority: Priority
    var createdDate: Date

    enum Priority: String, Codable {
        case low, medium, high
    }

    init(id: String = UUID().uuidString, title: String, description: String, assignedTo: String? = nil, priority: Priority = .medium) {
        self.id = id
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
        self.priority = priority
        self.createdDate = Date()
    }
}
