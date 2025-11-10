import Foundation

struct AppUser: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var bio: String?
    var familyId: String?
    var joinedDate: Date

    init(id: String, email: String, displayName: String, profileImageURL: String? = nil, bio: String? = nil, familyId: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.familyId = familyId
        self.joinedDate = Date()
    }

    // Custom decoding to handle missing familyId field in existing users
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        profileImageURL = try? container.decode(String.self, forKey: .profileImageURL)
        bio = try? container.decode(String.self, forKey: .bio)
        // familyId is optional and might not exist in older users
        familyId = try? container.decode(String.self, forKey: .familyId)
        joinedDate = try container.decode(Date.self, forKey: .joinedDate)
    }
}
