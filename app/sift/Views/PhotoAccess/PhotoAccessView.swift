import SwiftUI

/// Shown instead of the app while Sift can't read any photos.
struct PhotoAccessView: View {
  let access: PhotoAccess
  let onRequest: () -> Void

  @Environment(\.openURL) private var openURL

  var body: some View {
    Group {
      switch access {
      case .notDetermined:
        StatusView(
          .empty(
            title: "See your photos in Sift",
            systemImage: "photo.on.rectangle.angled",
            message: "Sift groups your photos into moments by time and place. Everything stays on your iPhone.",
            action: .init(title: "Allow photo access", perform: onRequest)
          )
        )
      case .denied:
        StatusView(
          .empty(
            title: "Photo access is off",
            systemImage: "lock",
            message: "Turn on photo access in Settings so Sift can group your photos.",
            action: .init(title: "Open Settings", perform: openSettings)
          )
        )
      case .restricted:
        StatusView(
          .empty(
            title: "Photo access is restricted",
            systemImage: "lock",
            message: "This iPhone doesn't let apps use photos. This is usually set by Screen Time or a device manager."
          )
        )
      case .full, .limited:
        EmptyView()
      }
    }
    .background(.canvas)
  }

  private func openSettings() {
    if let url = PhotoAccess.settingsURL {
      openURL(url)
    }
  }
}

#Preview("Not asked yet") {
  PhotoAccessView(access: .notDetermined, onRequest: {})
}

#Preview("Denied") {
  PhotoAccessView(access: .denied, onRequest: {})
}

#Preview("Restricted") {
  PhotoAccessView(access: .restricted, onRequest: {})
}
