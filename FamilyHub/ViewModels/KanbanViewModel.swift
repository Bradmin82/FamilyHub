import Foundation
import FirebaseFirestore

class KanbanViewModel: ObservableObject {
    @Published var boards: [KanbanBoard] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func fetchBoards(userId: String) {
        isLoading = true
        db.collection("kanbanBoards")
            .whereField("members", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false

                guard let documents = snapshot?.documents else {
                    print("Error fetching boards: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self?.boards = documents.compactMap { document in
                    try? document.data(as: KanbanBoard.self)
                }
            }
    }

    func createBoard(name: String, description: String, userId: String) {
        let board = KanbanBoard(name: name, description: description, createdBy: userId)
        do {
            try db.collection("kanbanBoards").document(board.id).setData(from: board)
        } catch {
            print("Error creating board: \(error.localizedDescription)")
        }
    }

    func addTask(boardId: String, columnIndex: Int, task: KanbanTask) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if columnIndex < board.columns.count {
                board.columns[columnIndex].tasks.append(task)
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
            }
        }
    }

    func moveTask(boardId: String, fromColumn: Int, toColumn: Int, taskId: String) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if let taskIndex = board.columns[fromColumn].tasks.firstIndex(where: { $0.id == taskId }) {
                let task = board.columns[fromColumn].tasks.remove(at: taskIndex)
                board.columns[toColumn].tasks.append(task)
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
            }
        }
    }
}
