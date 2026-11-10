import CoreLocation
import Foundation

/// The parts of a photo that grouping uses. Contains no PhotoKit types, so grouping is unit testable.
nonisolated struct PhotoMeta: Identifiable, Sendable {
  /// `PHAsset.localIdentifier`.
  let id: String
  let date: Date
  let location: CLLocation?
}
