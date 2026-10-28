import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
struct RootView: View {
  var body: some View {
    TabView {
      Tab("Moments", systemImage: "square.stack") {
        MomentsView()
      }
      Tab("Vault", systemImage: "heart.text.square") {
        VaultView()
      }
    }
  }
}

#Preview {
  RootView()
}
