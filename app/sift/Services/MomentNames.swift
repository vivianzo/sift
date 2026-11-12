import CoreLocation
import Foundation
import Observation

/// Place names for moments, looked up with Apple's geocoder and saved on the device.
///
/// This is Sift's only network use: it sends a moment's coordinates to Apple, never photos.
/// Names are cached by location (rounded to about 100 m), so each place is looked up once.
@Observable
final class MomentNames {
  private var placeNames: [String: String]
  private let geocoder = CLGeocoder()
  private let defaults: UserDefaults
  private static let defaultsKey = "placeNames"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    self.placeNames = defaults.dictionary(forKey: Self.defaultsKey) as? [String: String] ?? [:]
  }

  /// The place name when there is one, otherwise a time name like "Saturday evening".
  func name(for moment: Moment) -> String {
    moment.location.flatMap { placeNames[Self.cacheKey(for: $0)] } ?? moment.timeName()
  }

  /// Looks up place names that aren't cached yet, one at a time.
  /// Stops early if the geocoder fails (offline, or Apple's rate limit); those moments keep
  /// their time name and get looked up next time.
  func lookUp(_ moments: [Moment]) async {
    for location in moments.compactMap(\.location) where placeNames[Self.cacheKey(for: location)] == nil {
      guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else { return }
      let name = Moment.placeName(
        venue: placemark.areasOfInterest?.first,
        neighborhood: placemark.subLocality,
        city: placemark.locality
      )
      guard let name else { continue }
      placeNames[Self.cacheKey(for: location)] = name
      defaults.set(placeNames, forKey: Self.defaultsKey)
    }
  }

  static func cacheKey(for location: CLLocation) -> String {
    String(format: "%.3f,%.3f", location.coordinate.latitude, location.coordinate.longitude)
  }
}
