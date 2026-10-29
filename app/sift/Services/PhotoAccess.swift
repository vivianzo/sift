import Photos
import UIKit

/// How much of the photo library Sift can read.
/// Always asks for read-write: reading needs it, and so does the Archive album (#14).
nonisolated enum PhotoAccess: Equatable {
  case notDetermined
  case full
  case limited
  case denied
  case restricted

  init(_ status: PHAuthorizationStatus) {
    switch status {
    case .authorized: self = .full
    case .limited: self = .limited
    case .denied: self = .denied
    case .restricted: self = .restricted
    case .notDetermined: self = .notDetermined
    @unknown default: self = .denied
    }
  }

  var canReadPhotos: Bool {
    self == .full || self == .limited
  }

  static var current: PhotoAccess {
    PhotoAccess(PHPhotoLibrary.authorizationStatus(for: .readWrite))
  }

  /// Sift's page in the Settings app, where the user can change photo access.
  @MainActor static var settingsURL: URL? {
    URL(string: UIApplication.openSettingsURLString)
  }

  static func request() async -> PhotoAccess {
    PhotoAccess(await PHPhotoLibrary.requestAuthorization(for: .readWrite))
  }
}
