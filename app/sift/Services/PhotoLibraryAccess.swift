import Observation
import Photos
import UIKit

/// Photo library permission for the whole app. Views read `status` and call these methods
/// instead of talking to PhotoKit or Settings themselves.
///
/// iOS only lets an app see the library with read-write access, and that same access lets
/// Sift create the Archive album, so the user is asked once.
@Observable
final class PhotoLibraryAccess {
  private(set) var status: PHAuthorizationStatus

  init(status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)) {
    self.status = status
  }

  /// Re-reads the status, e.g. after the user changed it in Settings.
  func refresh() {
    status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  }

  func request() async {
    status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
  }

  func openSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }
}
