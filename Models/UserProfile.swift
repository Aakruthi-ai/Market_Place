import Foundation

// MARK: - UserProfile
// Lightweight local representation of the signed-in user.
struct UserProfile: Identifiable, Equatable {
    let id: String        // Firebase Auth UID
    let email: String
    let displayName: String
}
