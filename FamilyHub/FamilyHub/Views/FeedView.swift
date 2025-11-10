import SwiftUI
import FirebaseFirestore

struct FeedView: View {
    @StateObject private var postViewModel = PostViewModel()
    @StateObject private var kanbanViewModel = KanbanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreatePost = false
    @State private var showFilter = false
    @State private var showPosts = true
    @State private var showBoards = true

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Filter options
                    HStack {
                        Button(action: { showPosts.toggle() }) {
                            HStack {
                                Image(systemName: showPosts ? "checkmark.circle.fill" : "circle")
                                Text("Posts")
                            }
                            .foregroundColor(showPosts ? .blue : .gray)
                        }

                        Button(action: { showBoards.toggle() }) {
                            HStack {
                                Image(systemName: showBoards ? "checkmark.circle.fill" : "circle")
                                Text("Boards")
                            }
                            .foregroundColor(showBoards ? .blue : .gray)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Boards section
                    if showBoards && !kanbanViewModel.boards.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Boards")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(kanbanViewModel.boards.prefix(3)) { board in
                                BoardCardView(board: board, kanbanViewModel: kanbanViewModel)
                                    .padding(.horizontal)
                            }

                            if kanbanViewModel.boards.count > 3 {
                                NavigationLink(destination: KanbanBoardListView()) {
                                    Text("View All Boards (\(kanbanViewModel.boards.count))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                        }
                        .padding(.bottom)
                    }

                    // Posts section
                    if showPosts {
                        ForEach(postViewModel.posts) { post in
                            PostCardView(post: post, postViewModel: postViewModel)
                        }
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
                if let userId = authViewModel.currentUser?.id {
                    postViewModel.fetchPosts(
                        userId: userId,
                        familyId: authViewModel.currentUser?.familyId,
                        relatedFamilyIds: authViewModel.currentUser?.relatedFamilyIds ?? []
                    )
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

struct PostCardView: View {
    let post: Post
    let postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingComments = false
    @State private var showingDetail = false
    @State private var userProfileImageURL: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let profileImageURL = userProfileImageURL,
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
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading) {
                    Text(post.userName)
                        .fontWeight(.semibold)
                    Text(post.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .onAppear {
                loadUserProfileImage()
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
                            .onTapGesture {
                                showingDetail = true
                            }
                        }
                    }
                }
            }

            HStack(spacing: 20) {
                Button(action: {
                    if let userId = authViewModel.currentUser?.id {
                        let isLiked = post.likes.contains(userId)
                        postViewModel.toggleLike(postId: post.id, userId: userId, isLiked: isLiked)
                    }
                }) {
                    HStack {
                        Image(systemName: post.likes.contains(authViewModel.currentUser?.id ?? "") ? "heart.fill" : "heart")
                            .foregroundColor(post.likes.contains(authViewModel.currentUser?.id ?? "") ? .red : .gray)
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
        .sheet(isPresented: $showingDetail) {
            PostDetailView(post: post, postViewModel: postViewModel)
        }
    }

    private func loadUserProfileImage() {
        Firestore.firestore()
            .collection("users")
            .document(post.userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let profileImageURL = data["profileImageURL"] as? String {
                    self.userProfileImageURL = profileImageURL
                }
            }
    }
}

struct PostDetailView: View {
    let post: Post
    let postViewModel: PostViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImageIndex = 0
    @State private var userProfileImageURL: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        if let profileImageURL = userProfileImageURL,
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
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading) {
                            Text(post.userName)
                                .fontWeight(.semibold)
                            Text(post.timestamp, style: .relative)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .onAppear {
                        loadUserProfileImage()
                    }

                    // Images
                    if !post.imageURLs.isEmpty {
                        TabView(selection: $selectedImageIndex) {
                            ForEach(post.imageURLs.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: post.imageURLs[index])) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 400)

                        if post.imageURLs.count > 1 {
                            Text("\(selectedImageIndex + 1) of \(post.imageURLs.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                    // Content
                    Text(post.content)
                        .padding(.horizontal)

                    // Actions
                    HStack(spacing: 20) {
                        Button(action: {
                            if let userId = authViewModel.currentUser?.id {
                                let isLiked = post.likes.contains(userId)
                                postViewModel.toggleLike(postId: post.id, userId: userId, isLiked: isLiked)
                            }
                        }) {
                            HStack {
                                Image(systemName: post.likes.contains(authViewModel.currentUser?.id ?? "") ? "heart.fill" : "heart")
                                    .foregroundColor(post.likes.contains(authViewModel.currentUser?.id ?? "") ? .red : .gray)
                                Text("\(post.likes.count)")
                            }
                        }

                        HStack {
                            Image(systemName: "bubble.right")
                            Text("\(post.comments.count)")
                        }
                        .foregroundColor(.gray)

                        Spacer()
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // Comments section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comments")
                            .font(.headline)
                            .padding(.horizontal)

                        if post.comments.isEmpty {
                            Text("No comments yet")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(post.comments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.userName)
                                            .fontWeight(.semibold)
                                        Text(comment.timestamp, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Text(comment.content)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Post")
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

    private func loadUserProfileImage() {
        Firestore.firestore()
            .collection("users")
            .document(post.userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let profileImageURL = data["profileImageURL"] as? String {
                    self.userProfileImageURL = profileImageURL
                }
            }
    }
}
