import Photos
import SwiftUI

/// The two top-level tabs: Moments (sorting) and Vault (favorites).
/// Until Sift can read photos, shows the photo access screen instead.
struct RootView: View {
  @State private var access = PhotoLibraryAccess.status
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    Group {
      if access.canReadPhotos {
        tabs
      } else {
        PhotoAccessView(status: access) {
          Task { access = await PhotoLibraryAccess.request() }
        }
      }
    }
    // Access can change in Settings while the app is in the background.
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        access = PhotoLibraryAccess.status
      }
    }
  }

  private var tabs: some View {
    TabView {
      Tab("Moments", systemImage: "square.stack") {
        tabRoot { MomentsView() }
          .safeAreaInset(edge: .bottom) {
            if access == .limited {
              Banner(
                systemImage: "photo.badge.exclamationmark",
                message: "Sift can only see the photos you selected.",
                callToAction: .init(title: "Allow all", perform: PhotoLibraryAccess.openSettings)
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
}
