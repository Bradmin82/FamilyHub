import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var bio: String?
    var joinedDate: Date

    init(id: String, email: String, displayName: String, profileImageURL: String? = nil, bio: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.joinedDate = Date()
    }
}
