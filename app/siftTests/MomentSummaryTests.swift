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

  @Test(arguments: [1, 2, 3])
  func smallMomentsShowEveryPhoto(count: Int) throws {
    #expect(try moment(count: count).coverPhotos.map(\.id) == (0..<count).map { "p\($0)" })
  }

  @Test func biggerMomentsShowTheFirstMiddleAndLast() throws {
    #expect(try moment(count: 27).coverPhotos.map(\.id) == ["p0", "p13", "p26"])
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
