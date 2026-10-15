import SwiftUI

/// Favorites kept from each moment. Design is still open (#15).
struct VaultView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your vault is empty",
                systemImage: "heart",
                description: Text("Photos you keep while sorting will show up here.")
            )
            .navigationTitle("Vault")
        }
    }
}

#Preview {
    VaultView()
}
