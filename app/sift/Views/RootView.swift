import Photos
import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
/// Until Sift can read photos, shows the photo access screen instead.
struct RootView: View {
  @Environment(PhotoLibraryAccess.self) private var photoAccess
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    Group {
      switch photoAccess.status {
      case .authorized, .limited:
        tabs
      default:
        PhotoAccessView()
      }
    }
    // Access can change in Settings while the app is in the background.
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        photoAccess.refresh()
      }
    }
  }

  private var tabs: some View {
    TabView {
      Tab("Moments", systemImage: "square.stack") {
        tabRoot { MomentsView() }
          .safeAreaInset(edge: .bottom) {
            if photoAccess.status == .limited {
              Banner(
                systemImage: "photo.badge.exclamationmark",
                message: "Sift can only see the photos you selected.",
                button: ("Allow all", photoAccess.openSettings)
              )
              .padding(.horizontal, 16)
              .padding(.bottom, 8)
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
    .environment(PhotoLibraryAccess())
}
