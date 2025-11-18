import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var postViewModel: PostViewModel

    @State private var content = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var privacy: Privacy = .private
    @State private var useDefaultPrivacy = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }

                Section(header: Text("Privacy")) {
                    Toggle("Use Default Setting", isOn: $useDefaultPrivacy)
                        .onChange(of: useDefaultPrivacy) { _, newValue in
                            if newValue {
                                privacy = authViewModel.currentUser?.defaultPostPrivacy ?? .private
                            }
                        }

                    if !useDefaultPrivacy {
                        PrivacyPicker(selectedPrivacy: $privacy, showDescription: false)
                    } else {
                        HStack {
                            Image(systemName: privacy.icon)
                                .foregroundColor(.blue)
                            Text(privacy.displayName)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Default")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Photos")) {
                    Button(action: { showingImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Add Photos")
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: { selectedImages.remove(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .padding(4)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .onAppear {
                // Load default privacy setting
                privacy = authViewModel.currentUser?.defaultPostPrivacy ?? .private
            }
        }
    }

    private func createPost() {
        guard let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.displayName else { return }

        let imageData = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
        let familyId = authViewModel.currentUser?.familyId
        let relatedFamilyIds = authViewModel.currentUser?.relatedFamilyIds ?? []
        postViewModel.createPost(
            userId: userId,
            userName: userName,
            content: content,
            images: imageData,
            privacy: privacy,
            familyId: familyId,
            relatedFamilyIds: relatedFamilyIds
        )
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}
