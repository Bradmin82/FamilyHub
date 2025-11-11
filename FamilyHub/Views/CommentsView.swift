import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    let post: Post
    let postViewModel: PostViewModel

    @State private var newComment = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(post.comments) { comment in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(comment.userName)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(comment.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text(comment.content)
                        }
                        .padding(.vertical, 5)
                    }
                }

                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
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

    private func addComment() {
        guard let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.displayName else { return }

        let comment = Comment(userId: userId, userName: userName, content: newComment)
        postViewModel.addComment(postId: post.id, comment: comment)
        newComment = ""
    }
}
