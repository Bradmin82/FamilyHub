import Foundation

struct AppUser: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var bio: String?
    var familyId: String?
    var relatedFamilyIds: [String] // IDs of related families user is part of
    var joinedDate: Date

    // Default sharing preferences
    var defaultPostPrivacy: Privacy
    var defaultBoardPrivacy: Privacy
    var defaultPhotoPrivacy: Privacy

    init(id: String, email: String, displayName: String, profileImageURL: String? = nil, bio: String? = nil, familyId: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.familyId = familyId
        self.relatedFamilyIds = []
        self.joinedDate = Date()
        self.defaultPostPrivacy = .private
        self.defaultBoardPrivacy = .private
        self.defaultPhotoPrivacy = .private
    }

    // Custom decoding to handle missing fields in existing users
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        profileImageURL = try? container.decode(String.self, forKey: .profileImageURL)
        bio = try? container.decode(String.self, forKey: .bio)
        familyId = try? container.decode(String.self, forKey: .familyId)
        relatedFamilyIds = (try? container.decode([String].self, forKey: .relatedFamilyIds)) ?? []
        joinedDate = try container.decode(Date.self, forKey: .joinedDate)

        // Default privacy settings for existing users
        defaultPostPrivacy = (try? container.decode(Privacy.self, forKey: .defaultPostPrivacy)) ?? .private
        defaultBoardPrivacy = (try? container.decode(Privacy.self, forKey: .defaultBoardPrivacy)) ?? .private
        defaultPhotoPrivacy = (try? container.decode(Privacy.self, forKey: .defaultPhotoPrivacy)) ?? .private
    }
}
