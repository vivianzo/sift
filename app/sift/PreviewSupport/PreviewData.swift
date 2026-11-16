import CoreLocation
import Foundation

// Sample data for Xcode previews. Not inside `#if DEBUG`: `#Preview` blocks compile in Release
// builds too, so the data has to exist there.
extension Moment {
  /// Five photos at TD Garden, 10 minutes apart. The IDs aren't real photos, so thumbnails
  /// show their placeholder.
  static let preview = Moment(
    photos: (0..<5).map {
      PhotoMeta(
        id: "preview-\($0)",
        date: Date(timeIntervalSince1970: 1_793_581_200 + Double($0) * 600),
        location: CLLocation(latitude: 42.3662, longitude: -71.0621)
      )
    })!
}
