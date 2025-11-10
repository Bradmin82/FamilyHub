import SwiftUI
import FirebaseFirestore

struct FamilySetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var familyViewModel = FamilyViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var setupMode: SetupMode = .choose
    @State private var familyName = ""
    @State private var familyCode = ""
    @State private var showingInvites = false

    enum SetupMode {
        case choose
        case create
        case join
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if setupMode == .choose {
                    chooseView
                } else if setupMode == .create {
                    createFamilyView
                } else if setupMode == .join {
                    joinFamilyView
                }
            }
            .padding()
            .navigationTitle("Family Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip for now") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Check for pending invites
                if let email = authViewModel.currentUser?.email {
                    familyViewModel.checkPendingInvites(email: email)
                }
            }
            .sheet(isPresented: $showingInvites) {
                PendingInvitesView(familyViewModel: familyViewModel)
            }
        }
    }

    var chooseView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Set Up Your Family")
                .font(.title)
                .fontWeight(.bold)

            Text("Connect with your family members to share posts, photos, and tasks together.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            if !familyViewModel.pendingInvites.isEmpty {
                Button(action: { showingInvites = true }) {
                    HStack {
                        Image(systemName: "envelope.badge")
                        Text("You have \(familyViewModel.pendingInvites.count) invite(s)")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }

            Button(action: { setupMode = .create }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Family")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }

            Button(action: { setupMode = .join }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Join Existing Family")
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }

            Spacer()
        }
    }

    var createFamilyView: some View {
        VStack(spacing: 30) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Create Your Family")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Family Name")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("e.g., The Smiths", text: $familyName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if let errorMessage = familyViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: createFamily) {
                Text("Create Family")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(familyName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(familyName.isEmpty)

            Button("Back") {
                setupMode = .choose
            }
            .foregroundColor(.gray)

            Spacer()
        }
    }

    var joinFamilyView: some View {
        VStack(spacing: 30) {
            Image(systemName: "link")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Join a Family")
                .font(.title2)
                .fontWeight(.bold)

            Text("Enter the family code shared with you")
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 8) {
                Text("Family Code")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("e.g., ABCD1234", text: $familyCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
            }

            if let errorMessage = familyViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: joinFamily) {
                Text("Join Family")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(familyCode.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(familyCode.isEmpty)

            Button("Back") {
                setupMode = .choose
            }
            .foregroundColor(.gray)

            Spacer()
        }
    }

    private func createFamily() {
        guard let userId = authViewModel.currentUser?.id else {
            print("❌ No user ID found")
            return
        }

        print("🏠 Creating family: \(familyName)")
        familyViewModel.createFamily(name: familyName, userId: userId) { family in
            if let family = family {
                print("✅ Family created, updating user...")
                // Update user's familyId
                updateUserFamily(familyId: family.id)
                dismiss()
            } else {
                print("❌ Failed to create family")
            }
        }
    }

    private func joinFamily() {
        guard let userId = authViewModel.currentUser?.id else { return }

        familyViewModel.joinFamily(code: familyCode, userId: userId) { success in
            if success, let familyId = familyViewModel.currentFamily?.id {
                // Update user's familyId
                updateUserFamily(familyId: familyId)
                dismiss()
            }
        }
    }

    private func updateUserFamily(familyId: String) {
        guard var user = authViewModel.currentUser else {
            print("❌ No current user to update")
            return
        }

        print("📝 Updating user \(user.id) with familyId: \(familyId)")
        user.familyId = familyId
        authViewModel.currentUser = user

        // Update in Firestore
        Firestore.firestore()
            .collection("users")
            .document(user.id)
            .updateData(["familyId": familyId]) { error in
                if let error = error {
                    print("❌ Error updating user familyId: \(error.localizedDescription)")
                } else {
                    print("✅ User familyId updated successfully")
                }
            }
    }
}

struct PendingInvitesView: View {
    @ObservedObject var familyViewModel: FamilyViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(familyViewModel.pendingInvites) { invite in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(invite.familyName)
                            .font(.headline)

                        Text("Invited by \(invite.invitedByName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack {
                            Button("Accept") {
                                acceptInvite(invite)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Decline") {
                                declineInvite(invite)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Family Invites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func acceptInvite(_ invite: FamilyInvite) {
        guard let userId = authViewModel.currentUser?.id else { return }

        familyViewModel.acceptInvite(invite: invite, userId: userId) { success in
            if success {
                // Update user's familyId
                var user = authViewModel.currentUser
                user?.familyId = invite.familyId
                authViewModel.currentUser = user

                try? Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .updateData(["familyId": invite.familyId])

                dismiss()
            }
        }
    }

    private func declineInvite(_ invite: FamilyInvite) {
        Firestore.firestore()
            .collection("familyInvites")
            .document(invite.id)
            .delete()
    }
}
