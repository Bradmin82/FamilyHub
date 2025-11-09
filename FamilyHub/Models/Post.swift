import Foundation

struct Post: Identifiable, Codable {
    var id: String
    var userId: String
    var userName: String
    var content: String
    var imageURLs: [String]
    var timestamp: Date
    var likes: [String] // Array of user IDs who liked
    var comments: [Comment]

    init(id: String = UUID().uuidString, userId: String, userName: String, content: String, imageURLs: [String] = []) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.content = content
        self.imageURLs = imageURLs
        self.timestamp = Date()
        self.likes = []
        self.comments = []
    }
}

struct Comment: Identifiable, Codable {
    var id: String
    var userId: String
    var userName: String
    var content: String
    var timestamp: Date

    init(id: String = UUID().uuidString, userId: String, userName: String, content: String) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.content = content
        self.timestamp = Date()
    }
}
