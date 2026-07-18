import Foundation
import FirebaseAuth

// MARK: - AuthManager
// Thin wrapper around FirebaseAuth. Kept separate from the ViewModel so the
// networking/SDK logic is testable independently of SwiftUI.
final class AuthManager {

    static let shared = AuthManager()
    private init() {}

    var currentUser: UserProfile? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserProfile(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? (user.email?.components(separatedBy: "@").first ?? "User")
        )
    }

    // Listens for auth state changes (login/logout) and reports the current user, if any.
    func addStateListener(_ handler: @escaping (UserProfile?) -> Void) {
        Auth.auth().addStateDidChangeListener { _, user in
            guard let user else {
                handler(nil)
                return
            }
            handler(UserProfile(
                id: user.uid,
                email: user.email ?? "",
                displayName: user.displayName ?? (user.email?.components(separatedBy: "@").first ?? "User")
            ))
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws -> UserProfile {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        // Save the chosen display name onto the Firebase user record
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        return UserProfile(id: result.user.uid, email: email, displayName: displayName)
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return UserProfile(
            id: result.user.uid,
            email: result.user.email ?? email,
            displayName: result.user.displayName ?? email.components(separatedBy: "@").first ?? "User"
        )
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
