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
                    kanbanViewModel.fetchBoards(userId: userId)
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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Board Details")) {
                    TextField("Board Name", text: $boardName)
                    TextField("Description", text: $boardDescription)
                }

                Section(header: Text("Privacy")) {
                    Picker("Who can see this board?", selection: $privacy) {
                        Text("Private").tag(Privacy.private)
                        Text("Family").tag(Privacy.family)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if privacy == .private {
                        Text("Only you can see this board")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("All family members can see this board")
                            .font(.caption)
                            .foregroundColor(.gray)
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
        }
    }

    private func createBoard() {
        guard let userId = authViewModel.currentUser?.id else { return }
        kanbanViewModel.createBoard(name: boardName, description: boardDescription, userId: userId, privacy: privacy)
        dismiss()
    }
}
