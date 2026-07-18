import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

// MARK: - FirebaseManager
// Handles all Firestore reads/writes and Storage image uploads for Listings.
// Kept as a single service so ViewModels never talk to the SDK directly.
final class FirebaseManager {

    static let shared = FirebaseManager()
    private init() {}

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let listingsCollection = "listings"

    // MARK: Fetch all listings, newest first
    func fetchListings() async throws -> [Listing] {
        let snapshot = try await db.collection(listingsCollection)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: Listing.self)
        }
    }

    // MARK: Real-time listener (optional, used for live updates on the list screen)
    func listenToListings(onChange: @escaping ([Listing]) -> Void) -> ListenerRegistration {
        db.collection(listingsCollection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    onChange([])
                    return
                }
                let listings = documents.compactMap { try? $0.data(as: Listing.self) }
                onChange(listings)
            }
    }

    // MARK: Upload an image to Storage, returning its public download URL
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FirebaseManager", code: 1,
                           userInfo: [NSLocalizedDescriptionKey: "Could not encode image"])
        }

        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("listing_images/\(filename)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // MARK: Create a new listing document
    func createListing(_ listing: Listing) async throws {
        _ = try db.collection(listingsCollection).addDocument(from: listing)
    }

    // MARK: Delete a listing (only the seller should be allowed — enforced by security rules too)
    func deleteListing(id: String) async throws {
        try await db.collection(listingsCollection).document(id).delete()
    }
}
