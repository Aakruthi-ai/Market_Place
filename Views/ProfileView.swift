import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.tint)
                    .padding(.top, 40)

                Text(authViewModel.user?.displayName ?? "")
                    .font(.title2.bold())

                Text(authViewModel.user?.email ?? "")
                    .foregroundStyle(.secondary)

                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                .buttonStyle(.bordered)
                .padding(.top, 20)

                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}
