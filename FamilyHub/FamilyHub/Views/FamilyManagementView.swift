import SwiftUI
import FirebaseFirestore

struct FamilyManagementView: View {
    @ObservedObject var familyViewModel: FamilyViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var inviteEmail = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingEditName = false
    @State private var editedFamilyName = ""
    @State private var memberToRemove: AppUser?
    @State private var showingRemoveConfirmation = false

    var isAdmin: Bool {
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id else { return false }
        return family.createdBy == userId
    }

    var body: some View {
        NavigationView {
            Form {
                if let family = familyViewModel.currentFamily {
                    Section(header: Text("Family Information")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(family.name)
                                    .font(.headline)

                                HStack {
                                    Text("Family Code:")
                                        .foregroundColor(.gray)
                                    Text(family.code)
                                        .fontWeight(.semibold)
                                    Button(action: {
                                        UIPasteboard.general.string = family.code
                                        alertMessage = "Family code copied!"
                                        showingAlert = true
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .font(.subheadline)
                            }

                            Spacer()

                            if isAdmin {
                                Button(action: {
                                    editedFamilyName = family.name
                                    showingEditName = true
                                }) {
                                    Text("Edit")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }

                    Section(header: Text("Invite by Email")) {
                        HStack {
                            TextField("Email address", text: $inviteEmail)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)

                            Button("Send") {
                                sendInvite()
                            }
                            .disabled(inviteEmail.isEmpty)
                        }

                        if let successMessage = familyViewModel.successMessage {
                            Text(successMessage)
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }

                    Section(header: Text("Family Members (\(familyViewModel.familyMembers.count))")) {
                        ForEach(familyViewModel.familyMembers) { member in
                            HStack {
                                if let profileImageURL = member.profileImageURL,
                                   let url = URL(string: profileImageURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(member.displayName)
                                        .fontWeight(.semibold)
                                    Text(member.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                if member.id == family.createdBy {
                                    Text("Creator")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                } else if isAdmin {
                                    Button(action: {
                                        memberToRemove = member
                                        showingRemoveConfirmation = true
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        Button("Set up your family") {
                            // Show family setup flow
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Family Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("Edit Family Name", isPresented: $showingEditName) {
                TextField("Family Name", text: $editedFamilyName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    updateFamilyName()
                }
            } message: {
                Text("Enter a new name for your family")
            }
            .alert("Remove Member", isPresented: $showingRemoveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    if let member = memberToRemove {
                        removeMember(member)
                    }
                }
            } message: {
                if let member = memberToRemove {
                    Text("Are you sure you want to remove \(member.displayName) from the family?")
                }
            }
        }
    }

    private func updateFamilyName() {
        guard var family = familyViewModel.currentFamily else { return }
        guard !editedFamilyName.isEmpty else { return }

        family.name = editedFamilyName

        do {
            try Firestore.firestore()
                .collection("families")
                .document(family.id)
                .setData(from: family)
            familyViewModel.currentFamily = family
            alertMessage = "Family name updated!"
            showingAlert = true
        } catch {
            print("❌ Error updating family name: \(error.localizedDescription)")
        }
    }

    private func removeMember(_ member: AppUser) {
        guard var family = familyViewModel.currentFamily else { return }

        // Remove from family memberIds
        family.memberIds.removeAll { $0 == member.id }

        // Update family in Firestore
        do {
            try Firestore.firestore()
                .collection("families")
                .document(family.id)
                .setData(from: family)

            // Remove familyId from user
            Firestore.firestore()
                .collection("users")
                .document(member.id)
                .updateData(["familyId": FieldValue.delete()])

            familyViewModel.currentFamily = family
            alertMessage = "\(member.displayName) removed from family"
            showingAlert = true
        } catch {
            print("❌ Error removing member: \(error.localizedDescription)")
        }
    }

    private func sendInvite() {
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.displayName else { return }

        familyViewModel.inviteByEmail(
            email: inviteEmail,
            familyId: family.id,
            familyName: family.name,
            invitedBy: userId,
            invitedByName: userName
        )

        inviteEmail = ""
    }
}
