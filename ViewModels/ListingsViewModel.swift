import Foundation
import FirebaseFirestore
import UIKit

@MainActor
final class ListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    // Filters applied client-side on top of the live Firestore feed
    var filteredListings: [Listing] {
        listings.filter { listing in
            let matchesSearch = searchText.isEmpty
                || listing.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil
                || listing.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    // Starts a live listener so new listings appear instantly without a manual refresh
    func startListening() {
        isLoading = true
        listener = FirebaseManager.shared.listenToListings { [weak self] listings in
            Task { @MainActor in
                self?.listings = listings
                self?.isLoading = false
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func createListing(
        title: String,
        description: String,
        price: Double,
        category: String,
        image: UIImage?,
        seller: UserProfile
    ) async -> Bool {
        do {
            var imageURL: String? = nil
            if let image {
                imageURL = try await FirebaseManager.shared.uploadImage(image)
            }

            let listing = Listing(
                title: title,
                description: description,
                price: price,
                category: category,
                imageURL: imageURL,
                sellerId: seller.id,
                sellerName: seller.displayName,
                createdAt: Date()
            )

            try await FirebaseManager.shared.createListing(listing)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteListing(_ listing: Listing) async {
        guard let id = listing.id else { return }
        do {
            try await FirebaseManager.shared.deleteListing(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
