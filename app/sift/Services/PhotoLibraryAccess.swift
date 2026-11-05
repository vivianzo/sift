import Photos

/// Photo library permission. iOS only lets an app see the library with read-write access,
/// and that same access lets Sift create the Archive album later (#14), so the user is asked once.
enum PhotoLibraryAccess {
  static var status: PHAuthorizationStatus {
    PHPhotoLibrary.authorizationStatus(for: .readWrite)
  }

  static func request() async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: .readWrite)
  }
}
