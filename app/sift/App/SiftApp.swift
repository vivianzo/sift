import SwiftUI

@main
struct SiftApp: App {
  @State private var photoAccess = PhotoLibraryAccess()
  @State private var photoLibrary = PhotoLibrary()
  @State private var momentNames = MomentNames()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(photoAccess)
        .environment(photoLibrary)
        .environment(momentNames)
    }
  }
}
