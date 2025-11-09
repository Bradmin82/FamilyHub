import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    init() {
        checkAuth()
    }

    func checkAuth() {
        if let firebaseUser = auth.currentUser {
            loadUserData(userId: firebaseUser.uid)
        }
    }

    func signUp(email: String, password: String, displayName: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let userId = result?.user.uid else { return }

            let newUser = User(id: userId, email: email, displayName: displayName)
            self?.saveUserData(user: newUser)
        }
    }

    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let userId = result?.user.uid else { return }
            self?.loadUserData(userId: userId)
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveUserData(user: User) {
        do {
            try db.collection("users").document(user.id).setData(from: user)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                return
            }

            do {
                let user = try snapshot.data(as: User.self)
                self?.currentUser = user
                self?.isAuthenticated = true
            } catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}
