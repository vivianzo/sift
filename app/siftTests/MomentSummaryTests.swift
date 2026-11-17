import Foundation
import Testing

@testable import sift

struct MomentSummaryTests {
  private var boston: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/New_York")!
    calendar.locale = Locale(identifier: "en_US")
    return calendar
  }

  /// `count` photos starting Thursday, Nov 5 2026 at 8:12 PM Boston time, `gap` minutes apart.
  private func moment(count: Int, gap: Double = 1) throws -> Moment {
    let start = try #require(
      boston.date(from: DateComponents(year: 2026, month: 11, day: 5, hour: 20, minute: 12)))
    let photos = (0..<count).map {
      PhotoMeta(id: "p\($0)", date: start.addingTimeInterval(Double($0) * gap * 60), location: nil)
    }
    return try #require(Moment(photos: photos))
  }

  /// Splits a moment's photos, in order, into stacks of the given sizes.
  private func stacks(_ moment: Moment, sizes: [Int]) -> [Stack] {
    var remaining = moment.photos[...]
    return sizes.compactMap { size in
      defer { remaining = remaining.dropFirst(size) }
      return Stack(photos: Array(remaining.prefix(size)))
    }
  }

  @Test(arguments: [1, 2, 3])
  func smallMomentsShowEveryPhoto(count: Int) throws {
    #expect(try moment(count: count).coverPhotos(from: nil).map(\.id) == (0..<count).map { "p\($0)" })
  }

  @Test func withoutStacksBiggerMomentsShowTheFirstMiddleAndLast() throws {
    #expect(try moment(count: 27).coverPhotos(from: nil).map(\.id) == ["p0", "p13", "p26"])
  }

  @Test func withStacksCoversAreTheMiddleOfTheThreeBiggest() throws {
    // Stacks p0–p1, p2–p6, p7, p8–p10, p11–p14.
    let moment = try moment(count: 15)
    let covers = moment.coverPhotos(from: stacks(moment, sizes: [2, 5, 1, 3, 4]))
    #expect(covers.map(\.id) == ["p4", "p13", "p9"])
  }

  @Test func tiedStacksKeepTheirOrder() throws {
    let moment = try moment(count: 8)
    let covers = moment.coverPhotos(from: stacks(moment, sizes: [2, 2, 2, 2]))
    #expect(covers.map(\.id) == ["p1", "p3", "p5"])
  }

  @Test func fewerStacksThanCoversShowsOnePerStack() throws {
    let moment = try moment(count: 6)
    #expect(moment.coverPhotos(from: stacks(moment, sizes: [6])).map(\.id) == ["p3"])
  }

  @Test func dayShowsWeekdayMonthAndDay() throws {
    #expect(DisplayCalendar(calendar: boston).day(of: try moment(count: 1).start) == "Thu, Nov 5")
  }

  @Test func dayUsesTheCalendarsTimeZone() throws {
    // 8:12 PM in Boston is already Friday in Lisbon.
    var lisbon = boston
    lisbon.timeZone = TimeZone(identifier: "Europe/Lisbon")!
    #expect(DisplayCalendar(calendar: lisbon).day(of: try moment(count: 1).start) == "Fri, Nov 6")
  }

  @Test(arguments: [
    (1, "photo", "1 photo"), (7, "photo", "7 photos"), (1, "moment", "1 moment"), (12, "moment", "12 moments"),
  ])
  func countedPicksThePlural(count: Int, noun: String, expected: String) {
    #expect(String.counted(count, noun) == expected)
  }
}
