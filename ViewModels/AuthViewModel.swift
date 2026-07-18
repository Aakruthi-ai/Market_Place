import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading = false

    var isSignedIn: Bool { user != nil }

    init() {
        // Keep local state in sync with Firebase Auth's own session persistence
        AuthManager.shared.addStateListener { [weak self] profile in
            Task { @MainActor in
                self?.user = profile
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            user = try await AuthManager.shared.signUp(email: email, password: password, displayName: displayName)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            user = try await AuthManager.shared.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try AuthManager.shared.signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
