import CoreLocation
import Foundation

extension Moment {
  /// A moment spread wider than this, like a day of sightseeing, is named after its city.
  static let maxSpreadForSpotName: CLLocationDistance = 500

  /// The average position of the photos that have a location.
  var center: CLLocation? {
    let coordinates = photos.compactMap(\.location?.coordinate)
    guard !coordinates.isEmpty else { return nil }
    let count = Double(coordinates.count)
    return CLLocation(
      latitude: coordinates.map(\.latitude).reduce(0, +) / count,
      longitude: coordinates.map(\.longitude).reduce(0, +) / count
    )
  }

  /// How far the farthest located photo is from `center`. Zero without locations.
  var spread: CLLocationDistance {
    guard let center else { return 0 }
    return photos.compactMap(\.location).map { $0.distance(from: center) }.max() ?? 0
  }

  /// "Saturday evening", from when the moment started. Used when there's no place name.
  func timeName(calendar: Calendar = .current) -> String {
    var weekday = Date.FormatStyle(date: .omitted, time: .omitted).weekday(.wide)
    weekday.calendar = calendar
    weekday.timeZone = calendar.timeZone
    weekday.locale = calendar.locale ?? .current
    let partOfDay = PartOfDay(hour: calendar.component(.hour, from: start))
    return "\(start.formatted(weekday)) \(partOfDay.rawValue)"
  }

  /// "TD Garden, Boston" or "Beacon Hill, Boston" for a moment in one spot, "Boston" for one
  /// spread around a city. Nil when the place has nothing to show.
  func placeName(at place: Place) -> String? {
    let spot = spread <= Self.maxSpreadForSpotName ? place.venue ?? place.neighborhood : nil
    switch (spot, place.city) {
    case (let spot?, let city?) where spot != city: return "\(spot), \(city)"
    case (let spot?, _): return spot
    case (nil, let city?): return city
    case (nil, nil): return place.venue ?? place.neighborhood
    }
  }
}
