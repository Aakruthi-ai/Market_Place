import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @ObservedObject var listingsViewModel: ListingsViewModel

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    private var isOwner: Bool {
        listing.sellerId == authViewModel.user?.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: URL(string: listing.imageURL ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(Color(.tertiarySystemFill))
                    }
                }
                .frame(height: 260)
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(listing.title)
                        .font(.title2.bold())

                    Text(listing.formattedPrice)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.tint)

                    Label(listing.category, systemImage: "tag")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    Text(listing.description)
                        .font(.body)

                    Divider()

                    Label("Sold by \(listing.sellerName)", systemImage: "person.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .confirmationDialog("Delete this listing?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await listingsViewModel.deleteListing(listing)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
