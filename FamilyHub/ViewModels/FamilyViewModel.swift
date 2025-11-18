import Foundation
import Combine
import FirebaseFirestore

struct FamilyInvite: Identifiable, Codable {
    var id: String
    var familyId: String
    var familyName: String
    var invitedEmail: String
    var invitedBy: String
    var invitedByName: String
    var createdDate: Date

    init(id: String = UUID().uuidString, familyId: String, familyName: String, invitedEmail: String, invitedBy: String, invitedByName: String) {
        self.id = id
        self.familyId = familyId
        self.familyName = familyName
        self.invitedEmail = invitedEmail.lowercased()
        self.invitedBy = invitedBy
        self.invitedByName = invitedByName
        self.createdDate = Date()
    }
}

class FamilyViewModel: ObservableObject {
    @Published var currentFamily: Family?
    @Published var familyMembers: [AppUser] = []
    @Published var pendingInvites: [FamilyInvite] = []
    @Published var relatedFamilies: [Family] = []
    @Published var relatedFamilyMembers: [String: [AppUser]] = [:] // familyId -> members
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let db = Firestore.firestore()

    // Create a new family
    func createFamily(name: String, userId: String, completion: @escaping (Family?) -> Void) {
        let family = Family(name: name, createdBy: userId)

        do {
            try db.collection("families").document(family.id).setData(from: family)
            self.currentFamily = family
            print("✅ Family created: \(family.name) with code: \(family.code)")
            completion(family)
        } catch {
            print("❌ Error creating family: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            completion(nil)
        }
    }

    // Join family by code
    func joinFamily(code: String, userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("families")
            .whereField("code", isEqualTo: code.uppercased())
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error finding family: \(error.localizedDescription)")
                    self?.errorMessage = "Family code not found"
                    completion(false)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    self?.errorMessage = "Family code not found"
                    completion(false)
                    return
                }

                do {
                    var family = try document.data(as: Family.self)

                    if !family.memberIds.contains(userId) {
                        family.memberIds.append(userId)
                        try self?.db.collection("families").document(family.id).setData(from: family)
                    }

                    self?.currentFamily = family
                    print("✅ Joined family: \(family.name)")
                    completion(true)
                } catch {
                    print("❌ Error joining family: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
    }

    // Send email invite
    func inviteByEmail(email: String, familyId: String, familyName: String, invitedBy: String, invitedByName: String) {
        let invite = FamilyInvite(
            familyId: familyId,
            familyName: familyName,
            invitedEmail: email,
            invitedBy: invitedBy,
            invitedByName: invitedByName
        )

        do {
            try db.collection("familyInvites").document(invite.id).setData(from: invite)
            print("✅ Invite sent to: \(email)")
            self.successMessage = "Invite sent to \(email)"
        } catch {
            print("❌ Error sending invite: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }

    // Check for pending invites for user's email
    func checkPendingInvites(email: String) {
        db.collection("familyInvites")
            .whereField("invitedEmail", isEqualTo: email.lowercased())
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching invites: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self?.pendingInvites = documents.compactMap { doc in
                    try? doc.data(as: FamilyInvite.self)
                }

                print("📧 Found \(self?.pendingInvites.count ?? 0) pending invites")
            }
    }

    // Accept invite
    func acceptInvite(invite: FamilyInvite, userId: String, completion: @escaping (Bool) -> Void) {
        // Add user to family
        let familyRef = db.collection("families").document(invite.familyId)

        familyRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error getting family: \(error.localizedDescription)")
                completion(false)
                return
            }

            do {
                var family = try snapshot?.data(as: Family.self)

                if !family!.memberIds.contains(userId) {
                    family!.memberIds.append(userId)
                    try self?.db.collection("families").document(family!.id).setData(from: family!)
                }

                // Delete the invite
                self?.db.collection("familyInvites").document(invite.id).delete()

                self?.currentFamily = family
                print("✅ Accepted invite to family: \(family!.name)")
                completion(true)
            } catch {
                print("❌ Error accepting invite: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // Load family for user
    func loadFamily(familyId: String) {
        db.collection("families").document(familyId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error loading family: \(error.localizedDescription)")
                    return
                }

                guard let family = try? snapshot?.data(as: Family.self) else { return }

                self?.currentFamily = family
                self?.loadFamilyMembers(memberIds: family.memberIds)
            }
    }

    // Load family members
    private func loadFamilyMembers(memberIds: [String]) {
        guard !memberIds.isEmpty else {
            self.familyMembers = []
            return
        }

        // Firestore 'in' queries support max 10 items, so batch if needed
        let batches = memberIds.chunked(into: 10)
        var allMembers: [AppUser] = []

        let group = DispatchGroup()

        for batch in batches {
            group.enter()
            db.collection("users")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error loading members: \(error.localizedDescription)")
                    } else {
                        let members = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: AppUser.self)
                        } ?? []
                        allMembers.append(contentsOf: members)
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) { [weak self] in
            self?.familyMembers = allMembers
            print("✅ Loaded \(allMembers.count) family members")
        }
    }

    // Link two families as related
    func linkRelatedFamily(fromFamilyId: String, toFamilyCode: String, completion: @escaping (Bool) -> Void) {
        // Find the family to link with by code
        db.collection("families")
            .whereField("code", isEqualTo: toFamilyCode.uppercased())
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error finding family: \(error.localizedDescription)")
                    self?.errorMessage = "Family code not found"
                    completion(false)
                    return
                }

                guard let targetFamily = snapshot?.documents.first,
                      let targetFamilyData = try? targetFamily.data(as: Family.self) else {
                    self?.errorMessage = "Family code not found"
                    completion(false)
                    return
                }

                // Add bidirectional relationship
                let fromFamilyRef = self?.db.collection("families").document(fromFamilyId)
                let toFamilyRef = self?.db.collection("families").document(targetFamilyData.id)

                // Add to fromFamily's relatedFamilyIds
                fromFamilyRef?.updateData([
                    "relatedFamilyIds": FieldValue.arrayUnion([targetFamilyData.id])
                ]) { error in
                    if let error = error {
                        print("❌ Error linking family: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }

                    // Add to toFamily's relatedFamilyIds
                    toFamilyRef?.updateData([
                        "relatedFamilyIds": FieldValue.arrayUnion([fromFamilyId])
                    ]) { error in
                        if let error = error {
                            print("❌ Error linking family: \(error.localizedDescription)")
                            self?.errorMessage = error.localizedDescription
                            completion(false)
                        } else {
                            print("✅ Families linked successfully")
                            self?.successMessage = "Family linked successfully!"
                            completion(true)
                        }
                    }
                }
            }
    }

    // Remove member from family (creator only)
    func removeMember(familyId: String, memberId: String, requesterId: String, completion: @escaping (Bool) -> Void) {
        let familyRef = db.collection("families").document(familyId)

        familyRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error getting family: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let family = try? snapshot?.data(as: Family.self) else {
                self?.errorMessage = "Family not found"
                completion(false)
                return
            }

            // Check if requester is the creator
            guard family.createdBy == requesterId else {
                self?.errorMessage = "Only the family creator can remove members"
                completion(false)
                return
            }

            // Can't remove the creator
            guard memberId != family.createdBy else {
                self?.errorMessage = "Cannot remove the family creator"
                completion(false)
                return
            }

            // Remove member
            familyRef.updateData([
                "memberIds": FieldValue.arrayRemove([memberId]),
                "silencedMemberIds": FieldValue.arrayRemove([memberId]) // Also remove from silenced if present
            ]) { error in
                if let error = error {
                    print("❌ Error removing member: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    print("✅ Member removed successfully")
                    self?.successMessage = "Member removed"

                    // Remove familyId from user
                    self?.db.collection("users").document(memberId).updateData([
                        "familyId": FieldValue.delete(),
                        "relatedFamilyIds": FieldValue.arrayRemove([familyId])
                    ])

                    completion(true)
                }
            }
        }
    }

    // Silence member (creator only)
    func silenceMember(familyId: String, memberId: String, requesterId: String, completion: @escaping (Bool) -> Void) {
        let familyRef = db.collection("families").document(familyId)

        familyRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error getting family: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let family = try? snapshot?.data(as: Family.self) else {
                self?.errorMessage = "Family not found"
                completion(false)
                return
            }

            // Check if requester is the creator
            guard family.createdBy == requesterId else {
                self?.errorMessage = "Only the family creator can silence members"
                completion(false)
                return
            }

            // Can't silence the creator
            guard memberId != family.createdBy else {
                self?.errorMessage = "Cannot silence the family creator"
                completion(false)
                return
            }

            // Silence member
            familyRef.updateData([
                "silencedMemberIds": FieldValue.arrayUnion([memberId])
            ]) { error in
                if let error = error {
                    print("❌ Error silencing member: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    print("✅ Member silenced")
                    self?.successMessage = "Member silenced"
                    completion(true)
                }
            }
        }
    }

    // Unsilence member (creator only)
    func unsilenceMember(familyId: String, memberId: String, requesterId: String, completion: @escaping (Bool) -> Void) {
        let familyRef = db.collection("families").document(familyId)

        familyRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error getting family: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let family = try? snapshot?.data(as: Family.self) else {
                self?.errorMessage = "Family not found"
                completion(false)
                return
            }

            // Check if requester is the creator
            guard family.createdBy == requesterId else {
                self?.errorMessage = "Only the family creator can unsilence members"
                completion(false)
                return
            }

            // Unsilence member
            familyRef.updateData([
                "silencedMemberIds": FieldValue.arrayRemove([memberId])
            ]) { error in
                if let error = error {
                    print("❌ Error unsilencing member: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    print("✅ Member unsilenced")
                    self?.successMessage = "Member unsilenced"
                    completion(true)
                }
            }
        }
    }

    // Load related families
    func loadRelatedFamilies(relatedFamilyIds: [String]) {
        guard !relatedFamilyIds.isEmpty else {
            self.relatedFamilies = []
            self.relatedFamilyMembers = [:]
            return
        }

        let batches = relatedFamilyIds.chunked(into: 10)
        var allFamilies: [Family] = []
        let group = DispatchGroup()

        for batch in batches {
            group.enter()
            db.collection("families")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("❌ Error loading related families: \(error.localizedDescription)")
                    } else {
                        let families = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: Family.self)
                        } ?? []
                        allFamilies.append(contentsOf: families)
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) { [weak self] in
            self?.relatedFamilies = allFamilies
            print("✅ Loaded \(allFamilies.count) related families")

            // Load members for each related family
            for family in allFamilies {
                self?.loadRelatedFamilyMembers(familyId: family.id, memberIds: family.memberIds)
            }
        }
    }

    // Load members for a specific related family
    private func loadRelatedFamilyMembers(familyId: String, memberIds: [String]) {
        guard !memberIds.isEmpty else {
            self.relatedFamilyMembers[familyId] = []
            return
        }

        let batches = memberIds.chunked(into: 10)
        var allMembers: [AppUser] = []
        let group = DispatchGroup()

        for batch in batches {
            group.enter()
            db.collection("users")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Error loading related family members: \(error.localizedDescription)")
                    } else {
                        let members = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: AppUser.self)
                        } ?? []
                        allMembers.append(contentsOf: members)
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) { [weak self] in
            self?.relatedFamilyMembers[familyId] = allMembers
            print("✅ Loaded \(allMembers.count) members for family \(familyId)")
        }
    }

    // Unlink related family (bidirectional removal)
    func unlinkRelatedFamily(fromFamilyId: String, relatedFamilyId: String, requesterId: String, completion: @escaping (Bool) -> Void) {
        let fromFamilyRef = db.collection("families").document(fromFamilyId)

        fromFamilyRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error getting family: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let family = try? snapshot?.data(as: Family.self) else {
                self?.errorMessage = "Family not found"
                completion(false)
                return
            }

            // Check if requester is the creator
            guard family.createdBy == requesterId else {
                self?.errorMessage = "Only the family creator can unlink related families"
                completion(false)
                return
            }

            // Remove from fromFamily's relatedFamilyIds
            fromFamilyRef.updateData([
                "relatedFamilyIds": FieldValue.arrayRemove([relatedFamilyId])
            ]) { error in
                if let error = error {
                    print("❌ Error unlinking family: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                // Remove from toFamily's relatedFamilyIds
                let toFamilyRef = self?.db.collection("families").document(relatedFamilyId)
                toFamilyRef?.updateData([
                    "relatedFamilyIds": FieldValue.arrayRemove([fromFamilyId])
                ]) { error in
                    if let error = error {
                        print("❌ Error unlinking family: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        print("✅ Families unlinked successfully")
                        self?.successMessage = "Family unlinked successfully!"
                        completion(true)
                    }
                }
            }
        }
    }
}

// Helper extension to chunk arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
