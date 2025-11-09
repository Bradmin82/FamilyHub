import SwiftUI

struct FeedView: View {
    @StateObject private var postViewModel = PostViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreatePost = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(postViewModel.posts) { post in
                        PostCardView(post: post, postViewModel: postViewModel)
                    }
                }
                .padding()
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView(postViewModel: postViewModel)
            }
            .onAppear {
                postViewModel.fetchPosts()
            }
        }
    }
}

struct PostCardView: View {
    let post: Post
    let postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text(post.userName)
                        .fontWeight(.semibold)
                    Text(post.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Text(post.content)
                .fixedSize(horizontal: false, vertical: true)

            if !post.imageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(post.imageURLs, id: \.self) { urlString in
                            AsyncImage(url: URL(string: urlString)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 250, height: 250)
                            .cornerRadius(10)
                        }
                    }
                }
            }

            HStack(spacing: 20) {
                Button(action: {
                    if let userId = authViewModel.currentUser?.id {
                        postViewModel.likePost(postId: post.id, userId: userId)
                    }
                }) {
                    HStack {
                        Image(systemName: post.likes.contains(authViewModel.currentUser?.id ?? "") ? "heart.fill" : "heart")
                        Text("\(post.likes.count)")
                    }
                }

                Button(action: { showingComments = true }) {
                    HStack {
                        Image(systemName: "bubble.right")
                        Text("\(post.comments.count)")
                    }
                }

                Spacer()
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post, postViewModel: postViewModel)
        }
    }
}
