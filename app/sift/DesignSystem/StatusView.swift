import SwiftUI

/// Full-screen message for when a screen has nothing to show yet:
/// empty, still loading, or failed.
struct StatusView: View {
  enum Status {
    case empty(title: String, systemImage: String, message: String)
    case loading(message: String)
    case failed(message: String, retry: () -> Void)
  }

  let status: Status

  init(_ status: Status) {
    self.status = status
  }

  var body: some View {
    switch status {
    case .empty(let title, let systemImage, let message):
      ContentUnavailableView {
        Label(title, systemImage: systemImage).font(.heading)
      } description: {
        Text(message).font(.bodyText).foregroundStyle(.muted)
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

#Preview("Empty") {
  StatusView(.empty(title: "Nothing here", systemImage: "photo", message: "Photos will show up here."))
}

#Preview("Loading") {
  StatusView(.loading(message: "Grouping your photos…"))
}

#Preview("Failed") {
  StatusView(.failed(message: "Couldn't read your photo library.", retry: {}))
}
