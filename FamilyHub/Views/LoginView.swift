import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUpMode = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("FamilyHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding()

                if isSignUpMode {
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    if isSignUpMode {
                        authViewModel.signUp(email: email, password: password, displayName: displayName)
                    } else {
                        authViewModel.signIn(email: email, password: password)
                    }
                }) {
                    Text(isSignUpMode ? "Sign Up" : "Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                if !isSignUpMode {
                    Text("or")
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)

                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Sign in with Google")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                Button(action: {
                    isSignUpMode.toggle()
                }) {
                    Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.footnote)
                }
            }
            .padding()
            .navigationTitle("")
        }
    }
}
