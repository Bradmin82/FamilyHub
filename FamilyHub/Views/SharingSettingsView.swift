import SwiftUI
import FirebaseFirestore

struct SharingSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var defaultPostPrivacy: Privacy
    @State private var defaultBoardPrivacy: Privacy
    @State private var defaultPhotoPrivacy: Privacy
    @State private var isSaving = false
    @State private var showingSaveAlert = false

    init() {
        // Initialize with current user settings or defaults
        _defaultPostPrivacy = State(initialValue: .private)
        _defaultBoardPrivacy = State(initialValue: .private)
        _defaultPhotoPrivacy = State(initialValue: .private)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Default Sharing Settings")) {
                    Text("Set your default privacy levels for new content. You can always change the privacy when creating posts, boards, or uploading photos.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Section(header: Text("Posts")) {
                    CompactPrivacyPicker(selectedPrivacy: $defaultPostPrivacy)
                }

                Section(header: Text("Boards")) {
                    CompactPrivacyPicker(selectedPrivacy: $defaultBoardPrivacy)
                }

                Section(header: Text("Photos")) {
                    CompactPrivacyPicker(selectedPrivacy: $defaultPhotoPrivacy)
                }

                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Sharing Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
            .alert("Settings Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your default sharing settings have been updated")
            }
        }
    }

    private func loadCurrentSettings() {
        guard let user = authViewModel.currentUser else { return }
        defaultPostPrivacy = user.defaultPostPrivacy
        defaultBoardPrivacy = user.defaultBoardPrivacy
        defaultPhotoPrivacy = user.defaultPhotoPrivacy
    }

    private func saveSettings() {
        guard var user = authViewModel.currentUser else { return }

        isSaving = true

        user.defaultPostPrivacy = defaultPostPrivacy
        user.defaultBoardPrivacy = defaultBoardPrivacy
        user.defaultPhotoPrivacy = defaultPhotoPrivacy

        do {
            try Firestore.firestore()
                .collection("users")
                .document(user.id)
                .setData(from: user)

            authViewModel.currentUser = user
            isSaving = false
            showingSaveAlert = true
        } catch {
            print("❌ Error saving sharing settings: \(error.localizedDescription)")
            isSaving = false
        }
    }
}
