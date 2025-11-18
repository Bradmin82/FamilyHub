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
    @State private var relatedFamilyCode = ""
    @State private var memberToSilence: AppUser?
    @State private var showingSilenceConfirmation = false
    @State private var familyToUnlink: Family?
    @State private var showingUnlinkConfirmation = false
    @State private var isProcessing = false

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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(family.name)
                                    .font(.headline)
                                Spacer()
                                if isAdmin {
                                    Button(action: {
                                        editedFamilyName = family.name
                                        showingEditName = true
                                    }) {
                                        Text("Edit")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }

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
                                        .padding(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .font(.subheadline)
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

                    Section(header: Text("Link Related Family")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Connect with in-laws, extended family, or other related families")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack {
                                TextField("Enter family code", text: $relatedFamilyCode)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()

                                Button("Link") {
                                    linkRelatedFamily()
                                }
                                .disabled(relatedFamilyCode.isEmpty || isProcessing)
                            }
                        }

                        if !family.relatedFamilyIds.isEmpty {
                            Text("\(family.relatedFamilyIds.count) related family/families linked")
                                .font(.caption)
                                .foregroundColor(.blue)
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

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(member.displayName)
                                            .fontWeight(.semibold)
                                        if member.isOnline {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 8, height: 8)
                                        }
                                    }
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
                                    HStack(spacing: 12) {
                                        // Silence/Unsilence button
                                        if family.silencedMemberIds.contains(member.id) {
                                            Button(action: {
                                                unsilenceMember(member)
                                            }) {
                                                VStack(spacing: 2) {
                                                    Image(systemName: "speaker.wave.2.fill")
                                                        .font(.caption)
                                                    Text("Unsilence")
                                                        .font(.system(size: 8))
                                                }
                                                .foregroundColor(.orange)
                                            }
                                        } else {
                                            Button(action: {
                                                memberToSilence = member
                                                showingSilenceConfirmation = true
                                            }) {
                                                VStack(spacing: 2) {
                                                    Image(systemName: "speaker.slash.fill")
                                                        .font(.caption)
                                                    Text("Silence")
                                                        .font(.system(size: 8))
                                                }
                                                .foregroundColor(.gray)
                                            }
                                        }

                                        // Remove button
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
                    }

                    // Related Families Section
                    if !familyViewModel.relatedFamilies.isEmpty {
                        ForEach(familyViewModel.relatedFamilies) { relatedFamily in
                            Section(header: HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Related Family: \(relatedFamily.name)")
                                        .font(.headline)
                                    if let members = familyViewModel.relatedFamilyMembers[relatedFamily.id] {
                                        let onlineCount = members.filter { $0.isOnline }.count
                                        Text("\(members.count) members • \(onlineCount) online")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if isAdmin {
                                    Button(action: {
                                        familyToUnlink = relatedFamily
                                        showingUnlinkConfirmation = true
                                    }) {
                                        Text("Unlink")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }) {
                                if let members = familyViewModel.relatedFamilyMembers[relatedFamily.id] {
                                    ForEach(members) { member in
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

                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 6) {
                                                    Text(member.displayName)
                                                        .fontWeight(.semibold)
                                                    if member.isOnline {
                                                        Circle()
                                                            .fill(Color.green)
                                                            .frame(width: 8, height: 8)
                                                    }
                                                }
                                                Text(member.email)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            if member.id == relatedFamily.createdBy {
                                                Text("Creator")
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.purple.opacity(0.2))
                                                    .foregroundColor(.purple)
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                } else {
                                    Text("Loading members...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
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
            .alert("Silence Member", isPresented: $showingSilenceConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Silence", role: .destructive) {
                    if let member = memberToSilence {
                        silenceMember(member)
                    }
                }
            } message: {
                if let member = memberToSilence {
                    Text("Silence \(member.displayName)? They will remain in the family but won't be able to post or comment.")
                }
            }
            .alert("Unlink Family", isPresented: $showingUnlinkConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Unlink", role: .destructive) {
                    if let relatedFamily = familyToUnlink {
                        unlinkFamily(relatedFamily)
                    }
                }
            } message: {
                if let relatedFamily = familyToUnlink {
                    Text("Are you sure you want to unlink \(relatedFamily.name)? This will remove the family connection.")
                }
            }
            .onAppear {
                // Load related families when view appears
                if let currentFamily = familyViewModel.currentFamily {
                    familyViewModel.loadRelatedFamilies(relatedFamilyIds: currentFamily.relatedFamilyIds)
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
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id else { return }

        isProcessing = true
        familyViewModel.removeMember(
            familyId: family.id,
            memberId: member.id,
            requesterId: userId
        ) { [self] success in
            isProcessing = false
            if success {
                alertMessage = "\(member.displayName) removed from family"
                showingAlert = true
            } else if let errorMessage = familyViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
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

    private func linkRelatedFamily() {
        guard let family = familyViewModel.currentFamily else { return }

        isProcessing = true
        familyViewModel.linkRelatedFamily(
            fromFamilyId: family.id,
            toFamilyCode: relatedFamilyCode
        ) { [self] success in
            isProcessing = false
            if success {
                alertMessage = "Family linked successfully!"
                showingAlert = true
                relatedFamilyCode = ""
            } else if let errorMessage = familyViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }

    private func silenceMember(_ member: AppUser) {
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id else { return }

        isProcessing = true
        familyViewModel.silenceMember(
            familyId: family.id,
            memberId: member.id,
            requesterId: userId
        ) { [self] success in
            isProcessing = false
            if success {
                alertMessage = "\(member.displayName) has been silenced"
                showingAlert = true
            } else if let errorMessage = familyViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }

    private func unsilenceMember(_ member: AppUser) {
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id else { return }

        isProcessing = true
        familyViewModel.unsilenceMember(
            familyId: family.id,
            memberId: member.id,
            requesterId: userId
        ) { [self] success in
            isProcessing = false
            if success {
                alertMessage = "\(member.displayName) has been unsilenced"
                showingAlert = true
            } else if let errorMessage = familyViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }

    private func unlinkFamily(_ relatedFamily: Family) {
        guard let family = familyViewModel.currentFamily,
              let userId = authViewModel.currentUser?.id else { return }

        isProcessing = true
        familyViewModel.unlinkRelatedFamily(
            fromFamilyId: family.id,
            relatedFamilyId: relatedFamily.id,
            requesterId: userId
        ) { [self] success in
            isProcessing = false
            if success {
                alertMessage = "Unlinked from \(relatedFamily.name)"
                showingAlert = true
                // Refresh related families list
                familyViewModel.loadRelatedFamilies(relatedFamilyIds: family.relatedFamilyIds.filter { $0 != relatedFamily.id })
            } else if let errorMessage = familyViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
        }
    }
}
