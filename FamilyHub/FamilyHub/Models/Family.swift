import Foundation

struct Family: Identifiable, Codable {
    var id: String
    var name: String
    var code: String // Unique invite code like "SMITH2024"
    var memberIds: [String] // Array of user IDs
    var createdBy: String
    var createdDate: Date

    init(id: String = UUID().uuidString, name: String, createdBy: String) {
        self.id = id
        self.name = name
        self.code = Family.generateFamilyCode()
        self.memberIds = [createdBy]
        self.createdBy = createdBy
        self.createdDate = Date()
    }

    static func generateFamilyCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let randomLetters = String((0..<4).map{ _ in letters.randomElement()! })
        let randomNumbers = String((0..<4).map{ _ in numbers.randomElement()! })
        return "\(randomLetters)\(randomNumbers)"
    }
}

enum Privacy: String, Codable {
    case family = "family"
    case `private` = "private"
}
