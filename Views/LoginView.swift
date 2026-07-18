import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUpMode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .padding(.top, 40)

                Text("Marketplace")
                    .font(.largeTitle.bold())

                Text(isSignUpMode ? "Create an account to start selling" : "Sign in to continue")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    if isSignUpMode {
                        TextField("Display name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                    }

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.top, 12)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    Task {
                        if isSignUpMode {
                            await authViewModel.signUp(email: email, password: password, displayName: displayName)
                        } else {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isSignUpMode ? "Sign Up" : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || (isSignUpMode && displayName.isEmpty))

                Button(isSignUpMode ? "Already have an account? Sign in" : "New here? Create an account") {
                    isSignUpMode.toggle()
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
        }
    }
}
