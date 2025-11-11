import Foundation

enum FeedItemType: String, Codable {
    case post
    case boardCreated
    case boardUpdated
    case taskCompleted
    case photo
}

struct FeedItem: Identifiable, Codable {
    var id: String
    var type: FeedItemType
    var userId: String
    var userName: String
    var timestamp: Date
    var privacy: Privacy

    // Post-related
    var postContent: String?
    var postImageURLs: [String]?
    var likes: [String]
    var comments: [Comment]

    // Board-related
    var boardId: String?
    var boardName: String?
    var boardDescription: String?
    var taskTitle: String?
    var columnName: String?

    init(id: String = UUID().uuidString, type: FeedItemType, userId: String, userName: String, privacy: Privacy) {
        self.id = id
        self.type = type
        self.userId = userId
        self.userName = userName
        self.timestamp = Date()
        self.privacy = privacy
        self.likes = []
        self.comments = []
    }

    // Create from Post
    static func from(post: Post) -> FeedItem {
        var item = FeedItem(
            id: post.id,
            type: .post,
            userId: post.userId,
            userName: post.userName,
            privacy: post.privacy
        )
        item.postContent = post.content
        item.postImageURLs = post.imageURLs
        item.likes = post.likes
        item.comments = post.comments
        item.timestamp = post.timestamp
        return item
    }

    // Create from Board
    static func boardCreated(board: KanbanBoard, userName: String) -> FeedItem {
        var item = FeedItem(
            id: UUID().uuidString,
            type: .boardCreated,
            userId: board.createdBy,
            userName: userName,
            privacy: board.privacy
        )
        item.boardId = board.id
        item.boardName = board.name
        item.boardDescription = board.description
        item.timestamp = board.createdDate
        return item
    }
}

// Extension for displaying feed items
extension FeedItem {
    var displayText: String {
        switch type {
        case .post:
            return postContent ?? ""
        case .boardCreated:
            return "created a new board: \(boardName ?? "")"
        case .boardUpdated:
            return "updated board: \(boardName ?? "")"
        case .taskCompleted:
            return "completed task '\(taskTitle ?? "")' in \(columnName ?? "")"
        case .photo:
            return "shared \(postImageURLs?.count ?? 0) photo(s)"
        }
    }

    var icon: String {
        switch type {
        case .post: return "doc.text.fill"
        case .boardCreated: return "square.grid.2x2.fill"
        case .boardUpdated: return "square.grid.2x2"
        case .taskCompleted: return "checkmark.circle.fill"
        case .photo: return "photo.fill"
        }
    }

    var iconColor: String {
        switch type {
        case .post: return "blue"
        case .boardCreated: return "green"
        case .boardUpdated: return "orange"
        case .taskCompleted: return "purple"
        case .photo: return "pink"
        }
    }
}
