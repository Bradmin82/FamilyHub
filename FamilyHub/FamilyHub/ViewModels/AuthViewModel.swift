import Foundation
import Combine
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
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
                print("❌ Auth Error: \(error)")
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let userId = result?.user.uid else { return }

            print("✅ User created successfully: \(userId)")
            let newUser = AppUser(id: userId, email: email, displayName: displayName)
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

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ No client ID found")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                print("❌ Google Sign-In Error: \(error)")
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ No user or ID token")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            self?.auth.signIn(with: credential) { authResult, error in
                if let error = error {
                    print("❌ Firebase Auth Error: \(error)")
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let userId = authResult?.user.uid,
                      let email = authResult?.user.email,
                      let displayName = authResult?.user.displayName else { return }

                print("✅ Google Sign-In successful: \(userId)")

                // Check if user already exists in Firestore
                self?.db.collection("users").document(userId).getDocument { snapshot, error in
                    if let snapshot = snapshot, snapshot.exists {
                        // User exists, load their data
                        self?.loadUserData(userId: userId)
                    } else {
                        // New user, create profile
                        let newUser = AppUser(id: userId, email: email, displayName: displayName)
                        self?.saveUserData(user: newUser)
                    }
                }
            }
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

    private func saveUserData(user: AppUser) {
        do {
            try db.collection("users").document(user.id).setData(from: user)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            print("❌ Error saving user data: \(error)")
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
                let user = try snapshot.data(as: AppUser.self)
                self?.currentUser = user
                self?.isAuthenticated = true
            } catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}
