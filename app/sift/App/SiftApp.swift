import SwiftUI

@main
struct SiftApp: App {
  @State private var photoAccess = PhotoLibraryAccess()
  @State private var photoLibrary = PhotoLibrary()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(photoAccess)
        .environment(photoLibrary)
    }
  }
}
