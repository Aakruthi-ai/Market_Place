import Foundation
import FirebaseFirestore

// MARK: - Listing
// Represents a single item posted for sale.
// Codable + @DocumentID lets Firestore map documents to/from this struct automatically.
struct Listing: Identifiable, Codable {
    @DocumentID var id: String?          // Auto-filled by Firestore with the document ID
    var title: String
    var description: String
    var price: Double
    var category: String
    var imageURL: String?                // Download URL from Firebase Storage
    var sellerId: String                 // UID of the user who posted it
    var sellerName: String
    var createdAt: Date

    static let categories = ["Electronics", "Fashion", "Furniture", "Books", "Toys", "Other"]

    // Convenience formatted price string, e.g. "$45.00"
    var formattedPrice: String {
        price.formatted(.currency(code: "USD"))
    }
}
