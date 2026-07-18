import SwiftUI
import PhotosUI

struct AddListingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var listingsViewModel = ListingsViewModel()

    @State private var title = ""
    @State private var description = ""
    @State private var priceText = ""
    @State private var category = Listing.categories.first!
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false

    private var price: Double? { Double(priceText) }

    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && price != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Add a photo", systemImage: "photo.badge.plus")
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }
                }

                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Price (USD)", text: $priceText)
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $category) {
                        ForEach(Listing.categories, id: \.self) { Text($0) }
                    }
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Post Listing")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .navigationTitle("Sell an item")
            .alert("Listing posted!", isPresented: $showSuccessAlert) {
                Button("OK") { resetForm() }
            }
        }
    }

    private func submit() async {
        guard let seller = authViewModel.user, let price else { return }
        isSubmitting = true
        let success = await listingsViewModel.createListing(
            title: title,
            description: description,
            price: price,
            category: category,
            image: selectedImage,
            seller: seller
        )
        isSubmitting = false
        if success { showSuccessAlert = true }
    }

    private func resetForm() {
        title = ""
        description = ""
        priceText = ""
        category = Listing.categories.first!
        selectedItem = nil
        selectedImage = nil
    }
}
