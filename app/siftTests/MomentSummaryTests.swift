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

  @Test func dateTextShowsTheDayAndTimeRange() throws {
    // 172 minutes: 8:12 to 11:04 PM.
    let text = try moment(count: 2, gap: 172).dateText(calendar: boston)
    #expect(text.hasPrefix("Thu, Nov 5 · 8:12"))
    #expect(text.contains("11:04"))
  }

  @Test func dateTextShowsOneTimeForAQuickMoment() throws {
    // iOS puts a narrow no-break space before "PM".
    let text = try moment(count: 1).dateText(calendar: boston).replacingOccurrences(of: "\u{202F}", with: " ")
    #expect(text == "Thu, Nov 5 · 8:12 PM")
  }
}
