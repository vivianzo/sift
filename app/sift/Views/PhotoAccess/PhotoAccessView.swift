import Photos
import SwiftUI

/// Shown instead of the app while Sift can't read any photos.
struct PhotoAccessView: View {
  let status: PHAuthorizationStatus
  let onRequest: () -> Void

  var body: some View {
    Group {
      switch status {
      case .notDetermined:
        StatusView(
          .message(
            title: "See your photos in Sift",
            systemImage: "photo.on.rectangle.angled",
            message: "Sift groups your photos into moments by time and place. Everything stays on your iPhone.",
            callToAction: .init(title: "Allow photo access", perform: onRequest)
          )
        )
      case .restricted:
        StatusView(
          .message(
            title: "Photo access is restricted",
            systemImage: "lock",
            message: "This iPhone doesn't let apps use photos. This is usually set by Screen Time or a device manager."
          )
        )
      case .authorized, .limited:
        EmptyView()
      case .denied:
        deniedMessage
      // A status added in a future iOS. Treat it as no access until we handle it.
      @unknown default:
        deniedMessage
      }
    }
    .background(.canvas)
  }

  private var deniedMessage: some View {
    StatusView(
      .message(
        title: "Photo access is off",
        systemImage: "lock",
        message: "Turn on photo access in Settings so Sift can group your photos.",
        callToAction: .init(title: "Open Settings", perform: PhotoLibraryAccess.openSettings)
      )
    )
  }
}

#Preview("Not asked yet") {
  PhotoAccessView(status: .notDetermined, onRequest: {})
}

#Preview("Denied") {
  PhotoAccessView(status: .denied, onRequest: {})
}

#Preview("Restricted") {
  PhotoAccessView(status: .restricted, onRequest: {})
}
