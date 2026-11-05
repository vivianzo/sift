import SwiftUI

/// Full-screen state for a screen that has no content to show yet.
struct StatusView: View {
  enum Status {
    case message(
      title: String, systemImage: String, message: String, button: (title: String, action: () -> Void)? = nil)
    case loading(message: String)
    case failed(message: String, retry: () -> Void)
  }

  let status: Status

  init(_ status: Status) {
    self.status = status
  }

  var body: some View {
    switch status {
    case .message(let title, let systemImage, let message, let button):
      ContentUnavailableView {
        Label(title, systemImage: systemImage).font(.heading)
      } description: {
        Text(message).font(.bodyText).foregroundStyle(.muted)
      } actions: {
        if let button {
          Button(button.title, action: button.action)
            .font(.label)
            .buttonStyle(.borderedProminent)
        }
      }
    case .loading(let message):
      ProgressView {
        Text(message).font(.note).foregroundStyle(.muted)
      }
    case .failed(let message, let retry):
      ContentUnavailableView {
        Label("Something went wrong", systemImage: "exclamationmark.triangle").font(.heading)
      } description: {
        Text(message).font(.bodyText).foregroundStyle(.muted)
      } actions: {
        Button("Try again", action: retry).font(.label)
      }
    }
  }
}

#Preview("Message") {
  StatusView(.message(title: "Nothing here", systemImage: "photo", message: "Photos will show up here."))
}

#Preview("Message with button") {
  StatusView(
    .message(
      title: "Photo access is off",
      systemImage: "lock",
      message: "Turn on photo access in Settings.",
      button: ("Open Settings", {})
    )
  )
}

#Preview("Loading") {
  StatusView(.loading(message: "Grouping your photos…"))
}

#Preview("Failed") {
  StatusView(.failed(message: "Couldn't read your photo library.", retry: {}))
}
