import CoreLocation
import Foundation

/// The parts of a photo that grouping needs. Free of PhotoKit so grouping (#5) can be unit tested.
nonisolated struct PhotoMeta: Identifiable, Sendable {
  /// `PHAsset.localIdentifier`.
  let id: String
  let date: Date
  let location: CLLocation?
}
