import Photos
import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
/// Until Sift can read photos, shows the photo access screen instead.
struct RootView: View {
  @Environment(PhotoLibraryAccess.self) private var photoAccess
  @Environment(PhotoLibrary.self) private var photoLibrary

  var body: some View {
    Group {
      switch photoAccess.status {
      case .authorized, .limited:
        tabs
      default:
        PhotoAccessView()
      }
    }
    .task(id: photoAccess.status) {
      loadPhotosIfAllowed()
    }
    // Access and photos can both change while the app is in the background, e.g. in Settings.
    // Unlike `scenePhase`, this doesn't fire at launch or after the permission prompt.
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      photoAccess.refresh()
      loadPhotosIfAllowed()
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

  private func loadPhotosIfAllowed() {
    if photoAccess.status == .authorized || photoAccess.status == .limited {
      photoLibrary.loadRecent()
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
    .environment(PhotoLibrary())
}
