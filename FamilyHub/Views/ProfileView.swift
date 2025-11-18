import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var postViewModel = PostViewModel()
    @StateObject private var familyViewModel = FamilyViewModel()
    @State private var showingEditProfile = false
    @State private var showingFamilyManagement = false
    @State private var showingSharingSettings = false
    @State private var selectedFamilyTab = 0 // 0 = Family, 1 = Related Families

    var userPosts: [Post] {
        postViewModel.posts.filter { $0.userId == authViewModel.currentUser?.id }
    }

    var body: some View {
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

                    // Family & Related Families Tabbed Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(familyViewModel.currentFamily != nil ? "My Families" : "Family")
                                .font(.headline)
                            Spacer()
                            Button("Manage") {
                                showingFamilyManagement = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }

                        if let family = familyViewModel.currentFamily {
                            // Tabs for Family vs Related Families
                            Picker("", selection: $selectedFamilyTab) {
                                Text("Family").tag(0)
                                if !familyViewModel.relatedFamilies.isEmpty {
                                    Text("Related Families").tag(1)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom, 8)

                            // Tab Content
                            if selectedFamilyTab == 0 {
                                // Immediate Family Tab
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(family.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)

                                        Text("Family Code: \(family.code)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 8)

                                // Family Members List
                                VStack(spacing: 8) {
                                    ForEach(familyViewModel.familyMembers) { member in
                                        HStack(spacing: 12) {
                                            // Profile Image
                                            if let profileImageURL = member.profileImageURL,
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
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .font(.system(size: 36))
                                                    .foregroundColor(.gray)
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 6) {
                                                    Text(member.displayName)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                    if member.isOnline {
                                                        Circle()
                                                            .fill(Color.green)
                                                            .frame(width: 6, height: 6)
                                                    }
                                                }

                                                if let lastSeen = member.lastSeen {
                                                    if member.isOnline {
                                                        Text("Online now")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.green)
                                                    } else {
                                                        Text("Last seen \(timeAgoSince(lastSeen))")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }

                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            } else {
                                // Related Families Tab
                                ForEach(familyViewModel.relatedFamilies) { relatedFamily in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(relatedFamily.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)

                                                if let members = familyViewModel.relatedFamilyMembers[relatedFamily.id] {
                                                    let onlineCount = members.filter { $0.isOnline }.count
                                                    Text("\(members.count) members • \(onlineCount) online")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.bottom, 8)

                                        // Related Family Members List
                                        if let members = familyViewModel.relatedFamilyMembers[relatedFamily.id] {
                                            VStack(spacing: 8) {
                                                ForEach(members) { member in
                                                    HStack(spacing: 12) {
                                                        // Profile Image
                                                        if let profileImageURL = member.profileImageURL,
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
                                                            .frame(width: 36, height: 36)
                                                            .clipShape(Circle())
                                                        } else {
                                                            Image(systemName: "person.circle.fill")
                                                                .font(.system(size: 36))
                                                                .foregroundColor(.gray)
                                                        }

                                                        VStack(alignment: .leading, spacing: 2) {
                                                            HStack(spacing: 6) {
                                                                Text(member.displayName)
                                                                    .font(.caption)
                                                                    .fontWeight(.medium)
                                                                if member.isOnline {
                                                                    Circle()
                                                                        .fill(Color.green)
                                                                        .frame(width: 6, height: 6)
                                                                }
                                                            }

                                                            if let lastSeen = member.lastSeen {
                                                                if member.isOnline {
                                                                    Text("Online now")
                                                                        .font(.system(size: 10))
                                                                        .foregroundColor(.green)
                                                                } else {
                                                                    Text("Last seen \(timeAgoSince(lastSeen))")
                                                                        .font(.system(size: 10))
                                                                        .foregroundColor(.gray)
                                                                }
                                                            }
                                                        }

                                                        Spacer()
                                                    }
                                                }
                                            }
                                        } else {
                                            Text("Loading members...")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
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
                // Load related families
                if let relatedFamilyIds = authViewModel.currentUser?.relatedFamilyIds {
                    familyViewModel.loadRelatedFamilies(relatedFamilyIds: relatedFamilyIds)
                }
            }
    }

    private func timeAgoSince(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
}
