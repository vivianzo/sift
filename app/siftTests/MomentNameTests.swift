import CoreLocation
import Foundation
import Testing

@testable import sift

@MainActor
struct MomentNameTests {
  private let tdGarden = CLLocation(latitude: 42.3662, longitude: -71.0621)

  private var boston: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/New_York")!
    calendar.locale = Locale(identifier: "en_US")
    return calendar
  }

  /// A one-photo moment at `hour:minute` on Saturday, Nov 7 2026, Boston time.
  private func moment(hour: Int, minute: Int = 0, at location: CLLocation? = nil) throws -> Moment {
    let date = try #require(
      boston.date(from: DateComponents(year: 2026, month: 11, day: 7, hour: hour, minute: minute)))
    return try #require(Moment(photos: [PhotoMeta(id: "p", date: date, location: location)]))
  }

  @Test(arguments: [
    (8, "Saturday morning"),
    (12, "Saturday afternoon"),
    (19, "Saturday evening"),
    (21, "Saturday evening"),
    (23, "Saturday night"),
    (2, "Saturday night"),
  ])
  func timeNameUsesTheStartTime(hour: Int, expected: String) throws {
    #expect(try moment(hour: hour).timeName(calendar: boston) == expected)
  }

  @Test func placeNamePrefersTheVenue() {
    #expect(Moment.placeName(venue: "TD Garden", neighborhood: "West End", city: "Boston") == "TD Garden, Boston")
  }

  @Test func placeNameFallsBackToTheNeighborhoodThenTheCity() {
    #expect(Moment.placeName(venue: nil, neighborhood: "Beacon Hill", city: "Boston") == "Beacon Hill, Boston")
    #expect(Moment.placeName(venue: nil, neighborhood: nil, city: "Boston") == "Boston")
    #expect(Moment.placeName(venue: "Fenway Park", neighborhood: nil, city: nil) == "Fenway Park")
    #expect(Moment.placeName(venue: nil, neighborhood: nil, city: nil) == nil)
  }

  @Test func placeNameDoesNotRepeatTheCity() {
    #expect(Moment.placeName(venue: nil, neighborhood: "Boston", city: "Boston") == "Boston")
  }

  @Test func cacheKeyRoundsToAbout100Meters() {
    let nearby = CLLocation(latitude: 42.36624, longitude: -71.06208)
    #expect(MomentNames.cacheKey(for: tdGarden) == "42.366,-71.062")
    #expect(MomentNames.cacheKey(for: nearby) == MomentNames.cacheKey(for: tdGarden))
  }

  @Test func usesTheCachedPlaceNameOrFallsBackToTime() throws {
    let defaults = try #require(UserDefaults(suiteName: "MomentNameTests"))
    defaults.removePersistentDomain(forName: "MomentNameTests")
    defaults.set([MomentNames.cacheKey(for: tdGarden): "TD Garden, Boston"], forKey: "placeNames")
    let names = MomentNames(defaults: defaults)

    #expect(names.name(for: try moment(hour: 20, at: tdGarden)) == "TD Garden, Boston")
    let noLocation = try moment(hour: 20)
    #expect(names.name(for: noLocation) == noLocation.timeName())
  }
}
