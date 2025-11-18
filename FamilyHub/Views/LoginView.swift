import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUpMode = false

    var body: some View {
        ZStack {
            // Tiled background with logo
            GeometryReader { geometry in
                let tileSize: CGFloat = 150
                let rows = Int(ceil(geometry.size.height / tileSize)) + 1
                let cols = Int(ceil(geometry.size.width / tileSize)) + 1

                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        Image("Logo")
                            .resizable()
                            .frame(width: tileSize, height: tileSize)
                            .opacity(0.03)
                            .position(
                                x: CGFloat(col) * tileSize + tileSize / 2,
                                y: CGFloat(row) * tileSize + tileSize / 2
                            )
                    }
                }
            }
            .ignoresSafeArea()

            // Content
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 60)

                    // Logo and Title
                    VStack(spacing: 16) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)

                        Text("FamilyConnection")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text(isSignUpMode ? "Create your account" : "Welcome back!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)

                    // Form Container
                    VStack(spacing: 16) {
                        if isSignUpMode {
                            ModernTextField(
                                icon: "person.fill",
                                placeholder: "Display Name",
                                text: $displayName
                            )
                            .autocapitalization(.words)
                        }

                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email
                        )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                        ModernSecureField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password
                        )

                        if let errorMessage = authViewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Button(action: {
                            if isSignUpMode {
                                authViewModel.signUp(email: email, password: password, displayName: displayName)
                            } else {
                                authViewModel.signIn(email: email, password: password)
                            }
                        }) {
                            Text(isSignUpMode ? "Sign Up" : "Sign In")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: 500)

                    if !isSignUpMode {
                        VStack(spacing: 16) {
                            HStack {
                                VStack { Divider() }
                                Text("or continue with")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                VStack { Divider() }
                            }
                            .padding(.vertical, 8)

                            SignInWithAppleButton(.signIn) { request in
                                request.requestedScopes = [.fullName, .email]
                                let appleRequest = authViewModel.signInWithApple()
                                request.nonce = appleRequest.nonce
                            } onCompletion: { result in
                                authViewModel.handleSignInWithAppleCompletion(result)
                            }
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 55)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                            Button(action: {
                                authViewModel.signInWithGoogle()
                            }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.title3)
                                    Text("Sign in with Google")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 500)
                    }

                    Button(action: {
                        withAnimation {
                            isSignUpMode.toggle()
                        }
                    }) {
                        Text(isSignUpMode ? "Already have an account? " : "Don't have an account? ")
                            .foregroundColor(.gray)
                        + Text(isSignUpMode ? "Sign In" : "Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 16)

                    Spacer()
                        .frame(height: 40)
                }
            }
        }
    }
}

// Custom text field components
struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ModernSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
