import CoreLocation
import Foundation

extension Moment {
  /// The first photo with a location, used to look up the moment's place name.
  var location: CLLocation? {
    photos.first(where: { $0.location != nil })?.location
  }

  /// "Saturday evening", from when the moment started. Used when there's no place name.
  func timeName(calendar: Calendar = .current) -> String {
    var weekday = Date.FormatStyle(date: .omitted, time: .omitted).weekday(.wide)
    weekday.calendar = calendar
    weekday.timeZone = calendar.timeZone
    weekday.locale = calendar.locale ?? .current
    let partOfDay =
      switch calendar.component(.hour, from: start) {
      case 5..<12: "morning"
      case 12..<17: "afternoon"
      case 17..<22: "evening"
      default: "night"
      }
    return "\(start.formatted(weekday)) \(partOfDay)"
  }

  /// "TD Garden, Boston", "Beacon Hill, Boston", or "Boston". Nil when there's nothing to show.
  static func placeName(venue: String?, neighborhood: String?, city: String?) -> String? {
    let place = venue ?? neighborhood
    switch (place, city) {
    case (let place?, let city?) where place != city: return "\(place), \(city)"
    case (let place?, _): return place
    case (nil, let city?): return city
    case (nil, nil): return nil
    }
  }
}
