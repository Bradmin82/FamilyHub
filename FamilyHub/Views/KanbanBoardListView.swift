import SwiftUI

struct KanbanBoardListView: View {
    @StateObject private var kanbanViewModel = KanbanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateBoard = false

    var body: some View {
        NavigationView {
            List {
                ForEach(kanbanViewModel.boards) { board in
                    NavigationLink(destination: KanbanBoardDetailView(board: board, kanbanViewModel: kanbanViewModel)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(board.name)
                                .font(.headline)
                            Text(board.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                            Text("\(board.members.count) members")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Boards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateBoard = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateBoard) {
                CreateBoardView(kanbanViewModel: kanbanViewModel)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    kanbanViewModel.fetchBoards(
                        userId: userId,
                        familyId: authViewModel.currentUser?.familyId,
                        relatedFamilyIds: authViewModel.currentUser?.relatedFamilyIds ?? []
                    )
                }
            }
        }
    }
}

struct CreateBoardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var kanbanViewModel: KanbanViewModel

    @State private var boardName = ""
    @State private var boardDescription = ""
    @State private var privacy: Privacy = .private
    @State private var useDefaultPrivacy = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Board Details")) {
                    TextField("Board Name", text: $boardName)
                    TextField("Description", text: $boardDescription)
                }

                Section(header: Text("Privacy")) {
                    Toggle("Use Default Setting", isOn: $useDefaultPrivacy)
                        .onChange(of: useDefaultPrivacy) { _, newValue in
                            if newValue {
                                privacy = authViewModel.currentUser?.defaultBoardPrivacy ?? .private
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
            }
            .navigationTitle("New Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createBoard()
                    }
                    .disabled(boardName.isEmpty)
                }
            }
            .onAppear {
                // Load default privacy setting
                privacy = authViewModel.currentUser?.defaultBoardPrivacy ?? .private
            }
        }
    }

    private func createBoard() {
        guard let userId = authViewModel.currentUser?.id else { return }
        kanbanViewModel.createBoard(name: boardName, description: boardDescription, userId: userId, privacy: privacy)
        dismiss()
    }
}
