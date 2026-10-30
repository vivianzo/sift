import Photos
import UIKit

/// Photo library permission. iOS only lets an app see the library with read-write access,
/// and that same access lets Sift create the Archive album later (#14), so the user is asked once.
enum PhotoLibraryAccess {
  static var status: PHAuthorizationStatus {
    PHPhotoLibrary.authorizationStatus(for: .readWrite)
  }

  static func request() async -> PHAuthorizationStatus {
    await PHPhotoLibrary.requestAuthorization(for: .readWrite)
  }

  /// Opens Sift's page in the Settings app, where the user can change photo access.
  @MainActor static func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}

extension PHAuthorizationStatus {
  /// `.limited` means the user picked specific photos; Sift can read those.
  nonisolated var canReadPhotos: Bool {
    self == .authorized || self == .limited
  }
}
