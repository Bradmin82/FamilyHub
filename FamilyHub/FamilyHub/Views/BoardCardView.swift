import SwiftUI

struct BoardCardView: View {
    let board: KanbanBoard
    @ObservedObject var kanbanViewModel: KanbanViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var totalTasks: Int {
        board.columns.reduce(0) { $0 + $1.tasks.count }
    }

    var completedTasks: Int {
        board.columns.last?.tasks.count ?? 0 // Assuming last column is "Done"
    }

    var body: some View {
        NavigationLink(destination: KanbanBoardDetailView(board: board, kanbanViewModel: kanbanViewModel)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Board icon and title
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(.blue)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(board.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            if !board.description.isEmpty {
                                Text(board.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                    }

                    Spacer()

                    // Privacy indicator
                    HStack(spacing: 4) {
                        Image(systemName: board.privacy.icon)
                            .font(.caption)
                        Text(board.privacy.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }

                Divider()

                // Board stats
                HStack(spacing: 20) {
                    // Columns
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.3.group.fill")
                            .font(.caption)
                        Text("\(board.columns.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("columns")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)

                    // Tasks
                    HStack(spacing: 6) {
                        Image(systemName: "checklist")
                            .font(.caption)
                        Text("\(totalTasks)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("tasks")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)

                    // Members
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(board.members.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("members")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)

                    Spacer()
                }

                // Progress bar (if there are tasks)
                if totalTasks > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(completedTasks)/\(totalTasks)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)

                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * CGFloat(completedTasks) / CGFloat(totalTasks), height: 6)
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                    }
                }

                // Created date
                Text(board.createdDate, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
