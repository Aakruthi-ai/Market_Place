import SwiftUI

struct ListingsView: View {
    @StateObject private var viewModel = ListingsViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                categoryFilterBar

                if viewModel.isLoading {
                    ProgressView("Loading listings…")
                        .padding(.top, 60)
                } else if viewModel.filteredListings.isEmpty {
                    ContentUnavailableView(
                        "No listings found",
                        systemImage: "tray",
                        description: Text("Try a different search or category.")
                    )
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredListings) { listing in
                            NavigationLink(value: listing) {
                                ListingCardView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Browse")
            .searchable(text: $viewModel.searchText, prompt: "Search listings")
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing, listingsViewModel: viewModel)
            }
            .onAppear { viewModel.startListening() }
            .onDisappear { viewModel.stopListening() }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                categoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(Listing.categories, id: \.self) { category in
                    categoryChip(title: category, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture(perform: action)
    }
}

// MARK: - Reusable grid card
struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: listing.imageURL ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Rectangle().fill(Color(.tertiarySystemFill))
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(listing.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(listing.formattedPrice)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// Needed so Listing can be used with navigationDestination(for:)
extension Listing: Hashable {
    static func == (lhs: Listing, rhs: Listing) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
