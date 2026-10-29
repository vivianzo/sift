import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
struct RootView: View {
  var body: some View {
    TabView {
      Tab("Moments", systemImage: "square.stack") {
        tabRoot { MomentsView() }
      }
      Tab("Vault", systemImage: "heart.text.square") {
        tabRoot { VaultView() }
      }
    }
  }

  // SwiftUI doesn't carry this background over to pushed screens, so those set their own.
  private func tabRoot(@ViewBuilder _ content: () -> some View) -> some View {
    NavigationStack {
      content().background(.canvas)
    }
  }
}

#Preview {
  RootView()
}
