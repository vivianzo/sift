import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
/// Until Sift can read photos, shows the photo access screen instead.
struct RootView: View {
  @State private var access = PhotoAccess.current
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    Group {
      if access.canReadPhotos {
        tabs
      } else {
        PhotoAccessView(access: access) {
          Task { access = await PhotoAccess.request() }
        }
      }
    }
    // Access can change in Settings while the app is in the background.
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        access = PhotoAccess.current
      }
    }
  }

  private var tabs: some View {
    TabView {
      Tab("Moments", systemImage: "square.stack") {
        tabRoot { MomentsView() }
          .safeAreaInset(edge: .bottom) {
            if access == .limited {
              LimitedAccessBanner()
            }
          }
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
