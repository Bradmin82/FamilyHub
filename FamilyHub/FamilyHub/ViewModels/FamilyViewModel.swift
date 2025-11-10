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
}

// Helper extension to chunk arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
