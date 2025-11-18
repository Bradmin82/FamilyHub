import Foundation
import Combine
import FirebaseFirestore

class KanbanViewModel: ObservableObject {
    @Published var boards: [KanbanBoard] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func fetchBoards(userId: String, familyId: String? = nil, relatedFamilyIds: [String] = []) {
        isLoading = true
        db.collection("kanbanBoards")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false

                guard let documents = snapshot?.documents else {
                    print("Error fetching boards: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let allBoards = documents.compactMap { document -> KanbanBoard? in
                    try? document.data(as: KanbanBoard.self)
                }

                // Filter boards based on privacy hierarchy
                self?.boards = allBoards.filter { board in
                    self?.canViewBoard(board, userId: userId, familyId: familyId, relatedFamilyIds: relatedFamilyIds) ?? false
                }
            }
    }

    private func canViewBoard(_ board: KanbanBoard, userId: String, familyId: String?, relatedFamilyIds: [String]) -> Bool {
        // Always show your own boards (created by you or you're a member)
        if board.createdBy == userId || board.members.contains(userId) {
            return true
        }

        // Check privacy level
        switch board.privacy {
        case .private:
            return false // Can't see other people's private boards

        case .family:
            // Must be in the SAME immediate family as the board creator
            guard let viewerFamilyId = familyId, let boardFamilyId = board.familyId else {
                return false
            }
            return viewerFamilyId == boardFamilyId

        case .familyAndRelated:
            // Must be in the same immediate family OR same related families
            if let viewerFamilyId = familyId, let boardFamilyId = board.familyId, viewerFamilyId == boardFamilyId {
                return true // Same family
            }
            // Check if viewer's family is in board's related families OR vice versa
            if let viewerFamilyId = familyId, board.relatedFamilyIds.contains(viewerFamilyId) {
                return true
            }
            if let boardFamilyId = board.familyId, relatedFamilyIds.contains(boardFamilyId) {
                return true
            }
            // Check if any of viewer's related families match board's related families
            return !relatedFamilyIds.isEmpty && !board.relatedFamilyIds.isEmpty &&
                   !Set(relatedFamilyIds).isDisjoint(with: Set(board.relatedFamilyIds))

        case .familyAndAllRelated:
            // Must be in the same immediate family OR any related family
            if let viewerFamilyId = familyId, let boardFamilyId = board.familyId, viewerFamilyId == boardFamilyId {
                return true // Same family
            }
            // Check if viewer's family is in board's related families OR vice versa
            if let viewerFamilyId = familyId, board.relatedFamilyIds.contains(viewerFamilyId) {
                return true
            }
            if let boardFamilyId = board.familyId, relatedFamilyIds.contains(boardFamilyId) {
                return true
            }
            // Check if any of viewer's related families match board's related families
            return !relatedFamilyIds.isEmpty && !board.relatedFamilyIds.isEmpty &&
                   !Set(relatedFamilyIds).isDisjoint(with: Set(board.relatedFamilyIds))

        case .public:
            return true // Everyone can see public boards
        }
    }

    func createBoard(name: String, description: String, userId: String, privacy: Privacy = .private, familyId: String? = nil, relatedFamilyIds: [String] = []) {
        let board = KanbanBoard(name: name, description: description, createdBy: userId, privacy: privacy, familyId: familyId, relatedFamilyIds: relatedFamilyIds)
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
                print("✅ Task moved successfully")
            }
        }
    }

    func moveTask(boardId: String, fromColumn: Int, toColumn: Int, taskId: String, toIndex: Int) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if let taskIndex = board.columns[fromColumn].tasks.firstIndex(where: { $0.id == taskId }) {
                let task = board.columns[fromColumn].tasks.remove(at: taskIndex)

                // If moving within the same column, adjust index if needed
                var insertIndex = toIndex
                if fromColumn == toColumn && taskIndex < toIndex {
                    insertIndex -= 1
                }

                // Ensure index is valid
                insertIndex = min(insertIndex, board.columns[toColumn].tasks.count)
                insertIndex = max(0, insertIndex)

                board.columns[toColumn].tasks.insert(task, at: insertIndex)
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
                print("✅ Task moved to position \(insertIndex)")
            }
        }
    }

    // Edit a task
    func updateTask(boardId: String, columnIndex: Int, task: KanbanTask) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if let taskIndex = board.columns[columnIndex].tasks.firstIndex(where: { $0.id == task.id }) {
                board.columns[columnIndex].tasks[taskIndex] = task
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
                print("✅ Task updated successfully")
            }
        }
    }

    // Delete a task
    func deleteTask(boardId: String, columnIndex: Int, taskId: String) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            board.columns[columnIndex].tasks.removeAll { $0.id == taskId }
            try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
            print("✅ Task deleted successfully")
        }
    }

    // Add a column
    func addColumn(boardId: String, columnName: String) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            let newColumn = KanbanColumn(name: columnName)
            board.columns.append(newColumn)
            try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
            print("✅ Column added successfully")
        }
    }

    // Rename a column
    func renameColumn(boardId: String, columnIndex: Int, newName: String) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if columnIndex < board.columns.count {
                board.columns[columnIndex].name = newName
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
                print("✅ Column renamed successfully")
            }
        }
    }

    // Delete a column
    func deleteColumn(boardId: String, columnIndex: Int) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else { return }

            if columnIndex < board.columns.count {
                board.columns.remove(at: columnIndex)
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
                print("✅ Column deleted successfully")
            }
        }
    }

    // Generate public share link
    func generateShareLink(boardId: String, completion: @escaping (String?) -> Void) {
        let boardRef = db.collection("kanbanBoards").document(boardId)

        boardRef.getDocument { [weak self] snapshot, error in
            guard var board = try? snapshot?.data(as: KanbanBoard.self) else {
                completion(nil)
                return
            }

            if board.shareToken == nil {
                board.shareToken = KanbanBoard.generateShareToken()
                try? self?.db.collection("kanbanBoards").document(boardId).setData(from: board)
            }

            if let shareToken = board.shareToken {
                let shareURL = "familyhub://board/\(shareToken)"
                completion(shareURL)
            } else {
                completion(nil)
            }
        }
    }

    // Update board privacy
    func updateBoardPrivacy(boardId: String, privacy: Privacy) {
        db.collection("kanbanBoards")
            .document(boardId)
            .updateData(["privacy": privacy.rawValue]) { error in
                if let error = error {
                    print("❌ Error updating privacy: \(error.localizedDescription)")
                } else {
                    print("✅ Privacy updated to \(privacy.rawValue)")
                }
            }
    }
}
