import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        // Simple animated swap between logged-out and logged-in states
        .animation(.default, value: authViewModel.isSignedIn)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ListingsView()
                .tabItem { Label("Browse", systemImage: "square.grid.2x2") }

            AddListingView()
                .tabItem { Label("Sell", systemImage: "plus.circle") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
