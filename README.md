# Marketplace — SwiftUI + Firebase Buy & Sell App

[![Build and Test iOS App](https://github.com/Aakruthi-ai/Market_Place/actions/workflows/build.yml/badge.svg)](https://github.com/Aakruthi-ai/Market_Place/actions/workflows/build.yml)

A small secondhand marketplace app: users sign up, browse listings, filter/search,
post items with a photo, and view/delete their own listings. Built to demonstrate
Swift, SwiftUI, backend/API integration, and real-time data — the core skills
listed in most iOS internship postings.

## What's included

```
MarketplaceApp/
├── App/
│   └── MarketplaceApp.swift        # App entry point, configures Firebase
├── Models/
│   ├── Listing.swift               # Firestore-mapped listing model
│   └── UserProfile.swift           # Local user representation
├── Services/
│   ├── AuthManager.swift           # Firebase Auth wrapper
│   └── FirebaseManager.swift       # Firestore CRUD + Storage image upload
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── ListingsViewModel.swift
└── Views/
    ├── RootView.swift              # Switches Login <-> Main tabs
    ├── LoginView.swift             # Sign in / sign up
    ├── ListingsView.swift          # Browse grid, search, category filter
    ├── ListingDetailView.swift     # Item detail + delete (owner only)
    ├── AddListingView.swift        # Post a new item with photo picker
    └── ProfileView.swift           # Sign out
```

---

## Step 1 — Create the Xcode project

1. Open Xcode → **File → New → Project → iOS → App**.
2. Product name: `MarketplaceApp`. Interface: **SwiftUI**. Language: **Swift**.
3. Uncheck "Use Core Data" (we're using Firestore instead).
4. Once created, delete the default `ContentView.swift` Xcode generates, then
   drag the `App/`, `Models/`, `Services/`, `ViewModels/`, and `Views/` folders
   from this project into your Xcode project navigator (check
   "Copy items if needed" and add to your app target).

## Step 2 — Create a Firebase project

1. Go to the [Firebase Console](https://console.firebase.google.com) → **Add project**.
2. Give it a name (e.g. `marketplace-app`) and finish the wizard (Google Analytics is optional).
3. Once created, click the **iOS** icon to add an iOS app.
   - iOS bundle ID: must exactly match your Xcode project's bundle identifier
     (Xcode → target → General → Identity → Bundle Identifier).
4. Download the generated **`GoogleService-Info.plist`** file.
5. Drag `GoogleService-Info.plist` into your Xcode project root (check "Copy items if needed").
   This file is how Firebase knows which project to talk to — do not skip this.

## Step 3 — Add the Firebase Swift Package

1. In Xcode: **File → Add Package Dependencies…**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Choose **Up to Next Major Version**, then add these library products to your target:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseFirestoreSwift` *(if your SDK version bundles it separately; recent
     versions include Codable support directly in `FirebaseFirestore`)*
   - `FirebaseStorage`

## Step 4 — Enable Auth, Firestore, and Storage in the Firebase Console

1. **Authentication** → Sign-in method → enable **Email/Password**.
2. **Firestore Database** → Create database → start in **test mode** for now
   (you'll lock it down with rules below before shipping).
3. **Storage** → Get started → also start in test mode initially.

## Step 5 — Set Firestore & Storage security rules

Once your app works end-to-end, replace the default "test mode" rules with these
(Console → Firestore/Storage → Rules tab):

**Firestore rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /listings/{listingId} {
      allow read: if true;                                  // anyone can browse
      allow create: if request.auth != null
                    && request.resource.data.sellerId == request.auth.uid;
      allow delete: if request.auth != null
                    && resource.data.sellerId == request.auth.uid;
    }
  }
}
```

**Storage rules:**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /listing_images/{fileName} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024; // 5MB limit
    }
  }
}
```

## Step 6 — Info.plist permissions

Photo picker (`PhotosPicker`) generally doesn't require an Info.plist entry on
modern iOS, but if you switch to `UIImagePickerController` or camera capture later,
add:
- `NSPhotoLibraryUsageDescription` — "Used to attach photos to your listing."
- `NSCameraUsageDescription` — "Used to take photos of items you're selling."

## Step 7 — Build and run

1. Select an iOS 17+ simulator (the code uses `ContentUnavailableView` and the
   `onChange(of:)` two-parameter closure syntax, both iOS 17+).
2. Cmd+R. Sign up with a test email/password, then post a listing with a photo.
3. Open the Firebase console's Firestore/Storage tabs to watch the data land in
   real time — this is a great thing to screen-record for a portfolio/demo.

## ScreenShot of the app
   <img width="1179" height="2556" alt="screenshot" src="https://github.com/user-attachments/assets/6f8af5ac-ccae-429e-b8ea-72c690dea7d9" />


## Notes for extending it further

- Add pull-to-refresh with `.refreshable {}` on the ScrollView.
- Add pagination with Firestore's `.limit(to:)` + `startAfter()` for large datasets.
- Add a "My Listings" filter using `sellerId == currentUser.id`.
- Swap category filtering to Firestore-side (`.whereField("category", isEqualTo:)`)
  once listings grow beyond what's practical to filter client-side.
- Consider Sign in with Apple (`AuthenticationServices`) instead of/alongside
  email-password for a smoother first-run experience.
