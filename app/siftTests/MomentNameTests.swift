import CoreLocation
import Foundation
import Testing

@testable import sift

@MainActor
struct MomentNameTests {
  private let tdGarden = CLLocation(latitude: 42.3662, longitude: -71.0621)
  private let bostonCommon = CLLocation(latitude: 42.3550, longitude: -71.0656)
  private let tdGardenPlace = Place(landmark: "TD Garden", neighborhood: "West End", city: "Boston")

  private var boston: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/New_York")!
    calendar.locale = Locale(identifier: "en_US")
    return calendar
  }

  /// Photos on Saturday, Nov 7 2026, starting at `hour` Boston time, one minute apart.
  private func moment(hour: Int, at locations: [CLLocation?] = [nil]) throws -> Moment {
    let start = try #require(boston.date(from: DateComponents(year: 2026, month: 11, day: 7, hour: hour)))
    let photos = locations.enumerated().map { index, location in
      PhotoMeta(id: "p\(index)", date: start.addingTimeInterval(Double(index) * 60), location: location)
    }
    return try #require(Moment(photos: photos))
  }

  @Test(arguments: [
    (8, "Saturday morning"),
    (12, "Saturday afternoon"),
    (19, "Saturday evening"),
    (21, "Saturday evening"),
    (23, "Saturday night"),
    (2, "Saturday night"),
  ])
  func weekdayAndPartOfDayUsesTheStartTime(hour: Int, expected: String) throws {
    let start = try moment(hour: hour).start
    #expect(DisplayCalendar(calendar: boston).weekdayAndPartOfDay(of: start) == expected)
  }

  @Test(arguments: [(4, PartOfDay.night), (5, .morning), (12, .afternoon), (17, .evening), (22, .night)])
  func partOfDayBoundaries(hour: Int, expected: PartOfDay) {
    #expect(PartOfDay(hour: hour) == expected)
  }

  @Test func centerIsTheAverageOfLocatedPhotos() throws {
    let moment = try moment(
      hour: 20,
      at: [CLLocation(latitude: 42.0, longitude: -71.0), nil, CLLocation(latitude: 42.2, longitude: -71.2)])
    let center = try #require(moment.center)
    #expect(abs(center.coordinate.latitude - 42.1) < 0.000_1)
    #expect(abs(center.coordinate.longitude - -71.1) < 0.000_1)
  }

  @Test func momentWithoutLocationsHasNoCenter() throws {
    let moment = try moment(hour: 20)
    #expect(moment.center == nil)
    #expect(moment.spread == 0)
  }

  @Test func momentInOneSpotIsNamedAfterTheSpot() throws {
    #expect(try moment(hour: 20, at: [tdGarden, tdGarden]).placeName(at: tdGardenPlace) == "TD Garden, Boston")
  }

  @Test func spreadOutMomentIsNamedAfterTheCity() throws {
    // TD Garden to Boston Common is about 1.3 km, so each is ~650 m from the center.
    let moment = try moment(hour: 14, at: [tdGarden, bostonCommon])
    #expect(moment.spread > Moment.maxSpreadForSpotName)
    #expect(moment.placeName(at: tdGardenPlace) == "Boston")
  }

  @Test func placeNameFallsBackToTheNeighborhoodThenTheCity() throws {
    let spot = try moment(hour: 11, at: [tdGarden])
    #expect(
      spot.placeName(at: Place(landmark: nil, neighborhood: "Beacon Hill", city: "Boston")) == "Beacon Hill, Boston")
    #expect(spot.placeName(at: Place(landmark: nil, neighborhood: nil, city: "Boston")) == "Boston")
    #expect(spot.placeName(at: Place(landmark: "Fenway Park", neighborhood: nil, city: nil)) == "Fenway Park")
    #expect(spot.placeName(at: Place(landmark: nil, neighborhood: nil, city: nil)) == nil)
  }

  @Test func placeNameDoesNotRepeatTheCity() throws {
    let spot = try moment(hour: 11, at: [tdGarden])
    #expect(spot.placeName(at: Place(landmark: nil, neighborhood: "Boston", city: "Boston")) == "Boston")
  }

  @Test func cacheKeyRoundsToAbout100Meters() {
    let nearby = CLLocation(latitude: 42.36624, longitude: -71.06208)
    #expect(MomentNames.cacheKey(for: tdGarden) == "42.366,-71.062")
    #expect(MomentNames.cacheKey(for: nearby) == MomentNames.cacheKey(for: tdGarden))
  }

  @Test func usesTheCachedPlaceOrFallsBackToTime() throws {
    let defaults = try #require(UserDefaults(suiteName: "MomentNameTests"))
    defaults.removePersistentDomain(forName: "MomentNameTests")
    let cached = [MomentNames.cacheKey(for: tdGarden): tdGardenPlace]
    defaults.set(try JSONEncoder().encode(cached), forKey: "places")
    let names = MomentNames(defaults: defaults)

    #expect(names.name(for: try moment(hour: 20, at: [tdGarden])) == "TD Garden, Boston")
    let noLocation = try moment(hour: 20)
    #expect(names.name(for: noLocation) == noLocation.timeName)
  }
}
