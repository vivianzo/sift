import Foundation

extension Moment {
  /// Up to three photos for a moment's card: the first, middle, and last.
  var coverPhotos: [PhotoMeta] {
    guard photos.count > 3 else { return photos }
    return [photos[0], photos[photos.count / 2], photos[photos.count - 1]]
  }

  /// "Thu, Nov 5", the day the moment started.
  var dateText: String {
    DisplayCalendar.current.day(of: start)
  }
}
