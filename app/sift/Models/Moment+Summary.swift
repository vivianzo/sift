import Foundation

extension Moment {
  /// Up to three photos for a moment's card: the first, middle, and last.
  var coverPhotos: [PhotoMeta] {
    guard photos.count > 3 else { return photos }
    return [photos[0], photos[photos.count / 2], photos[photos.count - 1]]
  }

  /// "Fri, Nov 5 · 8:12 – 11:04 PM", or one time for a moment under a minute long.
  func dateText(calendar: Calendar = .current) -> String {
    let locale = calendar.locale ?? .current
    var day = Date.FormatStyle(date: .omitted, time: .omitted).weekday(.abbreviated).month(.abbreviated).day()
    day.calendar = calendar
    day.timeZone = calendar.timeZone
    day.locale = locale
    let time =
      if end.timeIntervalSince(start) < 60 {
        start.formatted(
          Date.FormatStyle(
            date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone))
      } else {
        (start..<end).formatted(
          Date.IntervalFormatStyle(
            date: .omitted, time: .shortened, locale: locale, calendar: calendar, timeZone: calendar.timeZone))
      }
    return "\(start.formatted(day)) · \(time)"
  }
}
