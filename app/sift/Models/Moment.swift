import CoreLocation
import Foundation

/// Photos taken close together in time and place, like one concert or one day of a trip.
nonisolated struct Moment: Identifiable, Sendable {
  /// Oldest first. Never empty.
  let photos: [PhotoMeta]

  var id: String { photos[0].id }
  var start: Date { photos[0].date }
  var end: Date { photos[photos.count - 1].date }
}

extension Moment {
  /// A longer gap between two photos starts a new moment.
  static let maxGap: TimeInterval = 90 * 60
  /// Moving farther than this from the previous located photo starts a new moment.
  static let maxDistance: CLLocationDistance = 1_000

  /// Groups photos into moments, oldest first.
  ///
  /// A photo starts a new moment when it's more than `maxGap` after the previous photo, or more
  /// than `maxDistance` from the previous photo that has a location. Photos without a location
  /// are grouped by time only.
  static func group(_ photos: [PhotoMeta]) -> [Moment] {
    var moments: [Moment] = []
    var current: [PhotoMeta] = []
    var lastLocation: CLLocation?

    for photo in photos.sorted(by: { $0.date < $1.date }) {
      if let previous = current.last {
        let tooLate = photo.date.timeIntervalSince(previous.date) > maxGap
        let tooFar =
          if let location = photo.location, let lastLocation {
            location.distance(from: lastLocation) > maxDistance
          } else {
            false
          }
        if tooLate || tooFar {
          moments.append(Moment(photos: current))
          current = []
          lastLocation = nil
        }
      }
      current.append(photo)
      lastLocation = photo.location ?? lastLocation
    }
    if !current.isEmpty {
      moments.append(Moment(photos: current))
    }
    return moments
  }
}
