import Foundation
import Combine
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var errorMessage: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var currentNonce: String?

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

    func signInWithApple() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    print("❌ Invalid state: A login callback was received, but no login request was sent.")
                    return
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("❌ Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("❌ Unable to serialize token string from data")
                    return
                }

                let credential = OAuthProvider.appleCredential(
                    withIDToken: idTokenString,
                    rawNonce: nonce,
                    fullName: appleIDCredential.fullName
                )

                auth.signIn(with: credential) { [weak self] authResult, error in
                    if let error = error {
                        print("❌ Firebase Auth Error: \(error)")
                        self?.errorMessage = error.localizedDescription
                        return
                    }

                    guard let userId = authResult?.user.uid else { return }

                    print("✅ Sign in with Apple successful: \(userId)")

                    // Check if user already exists in Firestore
                    self?.db.collection("users").document(userId).getDocument { snapshot, error in
                        if let snapshot = snapshot, snapshot.exists {
                            // User exists, load their data
                            self?.loadUserData(userId: userId)
                        } else {
                            // New user, create profile with Apple ID info
                            let email = authResult?.user.email ?? "apple.user@privaterelay.appleid.com"
                            var displayName = authResult?.user.displayName ?? "Apple User"

                            // Try to get full name from Apple ID credential
                            if let fullName = appleIDCredential.fullName {
                                let firstName = fullName.givenName ?? ""
                                let lastName = fullName.familyName ?? ""
                                if !firstName.isEmpty || !lastName.isEmpty {
                                    displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                                }
                            }

                            let newUser = AppUser(id: userId, email: email, displayName: displayName)
                            self?.saveUserData(user: newUser)
                        }
                    }
                }
            }
        case .failure(let error):
            print("❌ Sign in with Apple Error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        // Set user offline before signing out
        if let userId = currentUser?.id {
            updateOnlineStatus(userId: userId, isOnline: false)
        }

        do {
            try auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helper Methods for Sign in with Apple

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
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
                // Update online status when user loads
                self?.updateOnlineStatus(userId: userId, isOnline: true)
            } catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func updateOnlineStatus(userId: String, isOnline: Bool) {
        let updates: [String: Any] = [
            "isOnline": isOnline,
            "lastSeen": Date()
        ]

        db.collection("users").document(userId).updateData(updates) { error in
            if let error = error {
                print("❌ Error updating online status: \(error.localizedDescription)")
            } else {
                print("✅ Online status updated: \(isOnline)")
            }
        }
    }
}
