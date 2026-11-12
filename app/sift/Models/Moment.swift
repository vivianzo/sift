import CoreLocation
import Foundation

/// Photos taken close together in time and place, like one concert or one day of a trip.
nonisolated struct Moment: Identifiable, Sendable {
  let id: String
  /// Oldest first.
  let photos: [PhotoMeta]
  let start: Date
  let end: Date

  /// Returns nil for an empty list, so every moment has at least one photo.
  init?(photos: [PhotoMeta]) {
    let sorted = photos.sorted { $0.date < $1.date }
    guard let first = sorted.first, let last = sorted.last else { return nil }
    self.id = first.id
    self.photos = sorted
    self.start = first.date
    self.end = last.date
  }
}

extension Moment {
  static let maxGap: TimeInterval = 90 * 60
  static let maxDistance: CLLocationDistance = 1_000

  /// Groups photos into moments, oldest first. Photos without a location are grouped by time only.
  static func group(_ photos: [PhotoMeta]) -> [Moment] {
    var groups: [[PhotoMeta]] = []
    for photo in photos.sorted(by: { $0.date < $1.date }) {
      if let current = groups.last, !startsNewMoment(photo, after: current) {
        groups[groups.count - 1].append(photo)
      } else {
        groups.append([photo])
      }
    }
    return groups.compactMap(Moment.init)
  }

  /// True when `photo` is more than `maxGap` after the moment's last photo, or more than
  /// `maxDistance` from its last photo with a location.
  private static func startsNewMoment(_ photo: PhotoMeta, after current: [PhotoMeta]) -> Bool {
    guard let previous = current.last else { return true }
    if photo.date.timeIntervalSince(previous.date) > maxGap {
      return true
    }
    guard let location = photo.location,
      let lastLocation = current.last(where: { $0.location != nil })?.location
    else {
      return false
    }
    return location.distance(from: lastLocation) > maxDistance
  }
}
