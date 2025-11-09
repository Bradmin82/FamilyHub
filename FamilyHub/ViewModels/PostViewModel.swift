import Foundation
import FirebaseFirestore
import FirebaseStorage

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchPosts() {
        isLoading = true
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.isLoading = false

                guard let documents = snapshot?.documents else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self?.posts = documents.compactMap { document in
                    try? document.data(as: Post.self)
                }
            }
    }

    func createPost(userId: String, userName: String, content: String, images: [Data]) {
        var post = Post(userId: userId, userName: userName, content: content)

        let group = DispatchGroup()
        var uploadedImageURLs: [String] = []

        for (index, imageData) in images.enumerated() {
            group.enter()
            let imagePath = "posts/\(post.id)/image_\(index).jpg"
            let storageRef = storage.reference().child(imagePath)

            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if error == nil {
                    storageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedImageURLs.append(url.absoluteString)
                        }
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            post.imageURLs = uploadedImageURLs
            do {
                try self?.db.collection("posts").document(post.id).setData(from: post)
            } catch {
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }

    func likePost(postId: String, userId: String) {
        let postRef = db.collection("posts").document(postId)
        postRef.updateData([
            "likes": FieldValue.arrayUnion([userId])
        ])
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
