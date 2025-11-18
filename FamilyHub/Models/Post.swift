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
    var privacy: Privacy // family or private
    var familyId: String? // Family ID of the post creator
    var relatedFamilyIds: [String] // Related family IDs of the post creator

    init(id: String = UUID().uuidString, userId: String, userName: String, content: String, imageURLs: [String] = [], privacy: Privacy = .private, familyId: String? = nil, relatedFamilyIds: [String] = []) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.content = content
        self.imageURLs = imageURLs
        self.timestamp = Date()
        self.likes = []
        self.comments = []
        self.privacy = privacy
        self.familyId = familyId
        self.relatedFamilyIds = relatedFamilyIds
    }

    // Custom decoding to handle missing privacy field, familyId and relatedFamilyIds in existing posts
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        userName = try container.decode(String.self, forKey: .userName)
        content = try container.decode(String.self, forKey: .content)
        imageURLs = try container.decode([String].self, forKey: .imageURLs)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        likes = try container.decode([String].self, forKey: .likes)
        comments = try container.decode([Comment].self, forKey: .comments)
        // Default to family for existing posts without privacy field
        privacy = (try? container.decode(Privacy.self, forKey: .privacy)) ?? .family
        familyId = try? container.decode(String.self, forKey: .familyId)
        relatedFamilyIds = (try? container.decode([String].self, forKey: .relatedFamilyIds)) ?? []
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
