import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var postViewModel = PostViewModel()

    var userPosts: [Post] {
        postViewModel.posts.filter { $0.userId == authViewModel.currentUser?.id }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)

                    if let user = authViewModel.currentUser {
                        Text(user.displayName)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if let bio = user.bio {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 30) {
                            VStack {
                                Text("\(userPosts.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Posts")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            VStack {
                                Text("\(userPosts.reduce(0) { $0 + $1.likes.count })")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Likes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    Text("My Posts")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    LazyVStack(spacing: 16) {
                        ForEach(userPosts) { post in
                            PostCardView(post: post, postViewModel: postViewModel)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .onAppear {
                postViewModel.fetchPosts()
            }
        }
    }
}
