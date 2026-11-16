import CoreLocation
import Foundation
import Observation

/// Place names for moments, looked up with Apple's geocoder and saved on the device.
///
/// This is Sift's only network use: it sends a moment's center to Apple, never photos.
@Observable
final class MomentNames {
  /// What the geocoder returned, keyed by the moment's center rounded to about 100 m.
  private var places: [String: Place]
  private let geocoder = CLGeocoder()
  private let defaults: UserDefaults
  private static let defaultsKey = "places"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    let saved = defaults.data(forKey: Self.defaultsKey)
    self.places = saved.flatMap { try? JSONDecoder().decode([String: Place].self, from: $0) } ?? [:]
  }

  /// A moment's name, using the first of these that exists:
  /// 1. Landmark and city ("TD Garden, Boston"), if the moment stays within 500 m
  /// 2. Neighborhood and city ("Beacon Hill, Boston"), same condition
  /// 3. City ("Boston"), for spread-out moments or when there's nothing more specific
  /// 4. Time ("Saturday evening"), when there's no location or the place hasn't been looked up
  func name(for moment: Moment) -> String {
    moment.center
      .flatMap { places[Self.cacheKey(for: $0)] }
      .flatMap { moment.placeName(at: $0) }
      ?? moment.timeName()
  }

  /// Looks up the places that aren't cached yet, one at a time.
  func lookUp(_ moments: [Moment]) async {
    for center in moments.compactMap(\.center) where places[Self.cacheKey(for: center)] == nil {
      // Stops at the first failure (offline, or Apple's rate limit). The rest keep their
      // time names and get looked up on the next load.
      guard let placemark = try? await geocoder.reverseGeocodeLocation(center).first else { return }
      places[Self.cacheKey(for: center)] = Place(
        landmark: placemark.areasOfInterest?.first,
        neighborhood: placemark.subLocality,
        city: placemark.locality
      )
      defaults.set(try? JSONEncoder().encode(places), forKey: Self.defaultsKey)
    }
  }

  static func cacheKey(for location: CLLocation) -> String {
    String(format: "%.3f,%.3f", location.coordinate.latitude, location.coordinate.longitude)
  }
}
