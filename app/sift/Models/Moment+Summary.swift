import Foundation

extension Moment {
  /// Up to three photos for a moment's card. With stacks, one from each of the three biggest
  /// (the middle shot, until there are best picks), biggest first. Without them, the first,
  /// middle, and last photo.
  func coverPhotos(from stacks: [Stack]?) -> [PhotoMeta] {
    if let stacks, !stacks.isEmpty {
      // `sorted` isn't stable, so ties go to the earlier stack explicitly.
      let biggest = stacks.enumerated()
        .sorted { ($0.element.photos.count, $1.offset) > ($1.element.photos.count, $0.offset) }
        .prefix(3)
      return biggest.map { $0.element.photos[$0.element.photos.count / 2] }
    }
    guard photos.count > 3 else { return photos }
    return [photos[0], photos[photos.count / 2], photos[photos.count - 1]]
  }

  /// "Thu, Nov 5", the day the moment started.
  var dateText: String {
    DisplayCalendar.current.day(of: start)
  }
}
