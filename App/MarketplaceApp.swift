import SwiftUI
import FirebaseCore

// MARK: - AppDelegate (needed to configure Firebase before SwiftUI launches)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MarketplaceApp: App {
    // Bridges the old-style AppDelegate into the SwiftUI App lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
