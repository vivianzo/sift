import SwiftUI

@main
struct SiftApp: App {
  @State private var photoAccess = PhotoLibraryAccess()
  @State private var photoLibrary: PhotoLibrary
  @State private var momentNames = MomentNames()
  @State private var photoStacks: PhotoStacks

  init() {
    let library = PhotoLibrary()
    _photoLibrary = State(initialValue: library)
    _photoStacks = State(initialValue: PhotoStacks(library: library))
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(photoAccess)
        .environment(photoLibrary)
        .environment(momentNames)
        .environment(photoStacks)
    }
  }
}
