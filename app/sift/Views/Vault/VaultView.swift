import SwiftUI

struct VaultView: View {
  var body: some View {
    NavigationStack {
      StatusView(.empty(
        title: "Your vault is empty",
        systemImage: "heart",
        message: "Photos you keep while sorting will show up here."
      ))
      .navigationTitle("Vault")
    }
  }
}

#Preview {
  VaultView()
}
