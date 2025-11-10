import Foundation

struct Family: Identifiable, Codable {
    var id: String
    var name: String
    var code: String // Unique invite code like "SMITH2024"
    var memberIds: [String] // Array of user IDs
    var createdBy: String
    var createdDate: Date
    var relatedFamilyIds: [String] // IDs of related families (extended family, in-laws, etc.)

    init(id: String = UUID().uuidString, name: String, createdBy: String) {
        self.id = id
        self.name = name
        self.code = Family.generateFamilyCode()
        self.memberIds = [createdBy]
        self.createdBy = createdBy
        self.createdDate = Date()
        self.relatedFamilyIds = []
    }

    // Custom decoding for backward compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)
        memberIds = try container.decode([String].self, forKey: .memberIds)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        relatedFamilyIds = (try? container.decode([String].self, forKey: .relatedFamilyIds)) ?? []
    }

    static func generateFamilyCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let randomLetters = String((0..<4).map{ _ in letters.randomElement()! })
        let randomNumbers = String((0..<4).map{ _ in numbers.randomElement()! })
        return "\(randomLetters)\(randomNumbers)"
    }
}

enum Privacy: String, Codable, CaseIterable {
    case `private` = "private"                           // Only me
    case family = "family"                                // Immediate family
    case familyAndRelated = "family_and_related"          // Immediate + one related family
    case familyAndAllRelated = "family_and_all_related"   // Immediate + all related families
    case `public` = "public"                              // Everyone

    var displayName: String {
        switch self {
        case .private: return "Private"
        case .family: return "Family"
        case .familyAndRelated: return "Family + Related"
        case .familyAndAllRelated: return "Family + All Related"
        case .public: return "Public"
        }
    }

    var description: String {
        switch self {
        case .private: return "Only you"
        case .family: return "Your immediate family"
        case .familyAndRelated: return "Your family and related families"
        case .familyAndAllRelated: return "Your family and all related families"
        case .public: return "Everyone, including people outside your family"
        }
    }

    var icon: String {
        switch self {
        case .private: return "lock.fill"
        case .family: return "person.3.fill"
        case .familyAndRelated: return "person.2.fill"
        case .familyAndAllRelated: return "person.3.sequence.fill"
        case .public: return "globe"
        }
    }
}
