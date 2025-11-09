import SwiftUI

struct PhotoSharingView: View {
    @StateObject private var postViewModel = PostViewModel()

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
            .navigationTitle("Photos")
            .onAppear {
                postViewModel.fetchPosts()
            }
        }
    }
}
