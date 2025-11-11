import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchPosts(userId: String? = nil, familyId: String? = nil, relatedFamilyIds: [String] = []) {
        isLoading = true
        print("🔄 Fetching posts... (userId: \(userId ?? "nil"), familyId: \(familyId ?? "nil"), related: \(relatedFamilyIds.count))")

        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false

                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("❌ No documents in snapshot")
                    return
                }

                print("📥 Received \(documents.count) documents")

                let allPosts = documents.compactMap { document -> Post? in
                    do {
                        let post = try document.data(as: Post.self)
                        return post
                    } catch {
                        print("❌ Error decoding post \(document.documentID): \(error)")
                        return nil
                    }
                }

                // Filter posts based on privacy hierarchy
                self?.posts = allPosts.filter { post in
                    self?.canViewPost(post, userId: userId, familyId: familyId, relatedFamilyIds: relatedFamilyIds) ?? false
                }

                print("📊 Total posts loaded after filtering: \(self?.posts.count ?? 0)")
            }
    }

    private func canViewPost(_ post: Post, userId: String?, familyId: String?, relatedFamilyIds: [String]) -> Bool {
        // Always show your own posts
        if let userId = userId, post.userId == userId {
            return true
        }

        // Check privacy level
        switch post.privacy {
        case .private:
            return false // Can't see other people's private posts

        case .family:
            // Must be in the same immediate family
            return familyId != nil

        case .familyAndRelated:
            // Must be in immediate family OR related families
            return familyId != nil || !relatedFamilyIds.isEmpty

        case .familyAndAllRelated:
            // Must be in immediate family OR any related family
            return familyId != nil || !relatedFamilyIds.isEmpty

        case .public:
            return true // Everyone can see public posts
        }
    }

    func createPost(userId: String, userName: String, content: String, images: [Data], privacy: Privacy = .private) {
        print("📝 Creating post with \(images.count) images, privacy: \(privacy.rawValue)")
        var post = Post(userId: userId, userName: userName, content: content, privacy: privacy)

        let group = DispatchGroup()
        var uploadedImageURLs: [String] = []

        for (index, imageData) in images.enumerated() {
            group.enter()
            let imagePath = "posts/\(post.id)/image_\(index).jpg"
            let storageRef = storage.reference().child(imagePath)

            print("📤 Uploading image \(index + 1) to: \(imagePath)")

            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("❌ Upload error for image \(index): \(error.localizedDescription)")
                    group.leave()
                } else {
                    print("✅ Image \(index) uploaded, getting URL...")
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("❌ Error getting download URL: \(error.localizedDescription)")
                        } else if let url = url {
                            print("✅ Got URL for image \(index): \(url.absoluteString)")
                            uploadedImageURLs.append(url.absoluteString)
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            post.imageURLs = uploadedImageURLs
            print("💾 Saving post with \(uploadedImageURLs.count) image URLs")
            do {
                try self?.db.collection("posts").document(post.id).setData(from: post)
                print("✅ Post saved successfully!")
            } catch {
                print("❌ Error creating post: \(error.localizedDescription)")
            }
        }
    }

    func toggleLike(postId: String, userId: String, isLiked: Bool) {
        let postRef = db.collection("posts").document(postId)
        if isLiked {
            // Unlike
            postRef.updateData([
                "likes": FieldValue.arrayRemove([userId])
            ])
        } else {
            // Like
            postRef.updateData([
                "likes": FieldValue.arrayUnion([userId])
            ])
        }
    }

    func addComment(postId: String, comment: Comment) {
        let postRef = db.collection("posts").document(postId)
        do {
            let commentData = try Firestore.Encoder().encode(comment)
            postRef.updateData([
                "comments": FieldValue.arrayUnion([commentData])
            ])
        } catch {
            print("Error adding comment: \(error.localizedDescription)")
        }
    }
}
