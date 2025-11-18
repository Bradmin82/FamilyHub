import SwiftUI

struct PhotoSharingView: View {
    @StateObject private var postViewModel = PostViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreatePost = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var photoPosts: [Post] {
        postViewModel.posts.filter { !$0.imageURLs.isEmpty }
    }

    var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            return Array(repeating: GridItem(.flexible()), count: 6)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }

    var body: some View {
        GeometryReader { geometry in
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
                                .frame(width: (geometry.size.width / CGFloat(columns.count)) - 2,
                                       height: (geometry.size.width / CGFloat(columns.count)) - 2)
                                .clipped()
                            }
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
