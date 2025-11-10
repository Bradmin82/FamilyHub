import SwiftUI

struct PhotoSharingView: View {
    @StateObject private var postViewModel = PostViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreatePost = false

    var photoPosts: [Post] {
        postViewModel.posts.filter { !$0.imageURLs.isEmpty }
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                if photoPosts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("No Photos Yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Share your first photo!")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(photoPosts) { post in
                            ForEach(post.imageURLs, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: (UIScreen.main.bounds.width / 3) - 2, height: (UIScreen.main.bounds.width / 3) - 2)
                                .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Photos")
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
                postViewModel.fetchPosts(
                    userId: authViewModel.currentUser?.id,
                    familyId: authViewModel.currentUser?.familyId
                )
            }
        }
    }
}
