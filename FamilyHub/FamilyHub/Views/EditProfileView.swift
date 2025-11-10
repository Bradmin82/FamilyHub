import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String
    @State private var bio: String
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isUploading = false

    init(user: AppUser) {
        _displayName = State(initialValue: user.displayName)
        _bio = State(initialValue: user.bio ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        VStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let profileImageURL = authViewModel.currentUser?.profileImageURL,
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
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                            }

                            Button(action: { showingImagePicker = true }) {
                                Text("Change Photo")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                }

                Section(header: Text("Display Name")) {
                    TextField("Display Name", text: $displayName)
                }

                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveProfile()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: Binding(
                    get: { selectedImage.map { [$0] } ?? [] },
                    set: { selectedImage = $0.first }
                ))
            }
        }
    }

    private func saveProfile() {
        guard var user = authViewModel.currentUser else { return }

        user.displayName = displayName
        user.bio = bio.isEmpty ? nil : bio

        if let image = selectedImage {
            isUploading = true
            uploadProfileImage(image) { url in
                user.profileImageURL = url
                updateUserInFirestore(user)
            }
        } else {
            updateUserInFirestore(user)
        }
    }

    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let userId = authViewModel.currentUser?.id,
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }

        let storage = Storage.storage()
        let imagePath = "profileImages/\(userId).jpg"
        let storageRef = storage.reference().child(imagePath)

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Error uploading profile image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }

    private func updateUserInFirestore(_ user: AppUser) {
        let db = Firestore.firestore()

        do {
            try db.collection("users").document(user.id).setData(from: user)
            authViewModel.currentUser = user
            print("✅ Profile updated successfully")
            isUploading = false
            dismiss()
        } catch {
            print("❌ Error updating profile: \(error.localizedDescription)")
            isUploading = false
        }
    }
}
