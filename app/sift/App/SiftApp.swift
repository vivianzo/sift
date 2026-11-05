import SwiftUI

@main
struct SiftApp: App {
  @State private var photoAccess = PhotoLibraryAccess()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(photoAccess)
    }
  }
}
