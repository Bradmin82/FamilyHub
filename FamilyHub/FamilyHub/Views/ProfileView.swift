import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var postViewModel = PostViewModel()
    @StateObject private var familyViewModel = FamilyViewModel()
    @State private var showingEditProfile = false
    @State private var showingFamilyManagement = false
    @State private var showingSharingSettings = false

    var userPosts: [Post] {
        postViewModel.posts.filter { $0.userId == authViewModel.currentUser?.id }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture
                    if let profileImageURL = authViewModel.currentUser?.profileImageURL,
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
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                    }

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

                        // Edit Profile Button
                        Button(action: { showingEditProfile = true }) {
                            Text("Edit Profile")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)

                        // Stats
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

                    // Family Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Family")
                                .font(.headline)
                            Spacer()
                            Button("Manage") {
                                showingFamilyManagement = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }

                        if let family = familyViewModel.currentFamily {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(family.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Family Code: \(family.code)")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text("\(familyViewModel.familyMembers.count) member(s)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        } else {
                            Button(action: { showingFamilyManagement = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Set up your family")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)

                        Button(action: { showingSharingSettings = true }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Default Sharing Settings")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
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
            .sheet(isPresented: $showingEditProfile) {
                if let user = authViewModel.currentUser {
                    EditProfileView(user: user)
                }
            }
            .sheet(isPresented: $showingFamilyManagement) {
                FamilyManagementView(familyViewModel: familyViewModel)
            }
            .sheet(isPresented: $showingSharingSettings) {
                SharingSettingsView()
            }
            .onAppear {
                postViewModel.fetchPosts(
                    userId: authViewModel.currentUser?.id,
                    familyId: authViewModel.currentUser?.familyId,
                    relatedFamilyIds: authViewModel.currentUser?.relatedFamilyIds ?? []
                )
                if let familyId = authViewModel.currentUser?.familyId {
                    familyViewModel.loadFamily(familyId: familyId)
                }
            }
        }
    }
}
