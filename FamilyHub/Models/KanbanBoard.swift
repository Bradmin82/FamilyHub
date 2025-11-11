import Foundation

struct KanbanBoard: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var createdBy: String
    var members: [String] // User IDs
    var columns: [KanbanColumn]
    var privacy: Privacy // family or private
    var shareToken: String? // For public URL sharing
    var createdDate: Date

    init(id: String = UUID().uuidString, name: String, description: String, createdBy: String, privacy: Privacy = .private) {
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
        self.privacy = privacy
        self.shareToken = nil
        self.createdDate = Date()
    }

    static func generateShareToken() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16).lowercased()
    }

    // Custom decoding to handle missing privacy field and shareToken
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        members = try container.decode([String].self, forKey: .members)
        columns = try container.decode([KanbanColumn].self, forKey: .columns)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        // Default to family for existing boards without privacy field
        privacy = (try? container.decode(Privacy.self, forKey: .privacy)) ?? .family
        shareToken = try? container.decode(String.self, forKey: .shareToken)
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
