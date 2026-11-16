import Foundation

/// The calendar, time zone, and language for every date shown in the app.
nonisolated struct DisplayCalendar: Sendable {
  let calendar: Calendar

  static var current: DisplayCalendar { DisplayCalendar(calendar: .autoupdatingCurrent) }

  /// "Thu, Nov 5"
  func day(of date: Date) -> String {
    date.formatted(style.weekday(.abbreviated).month(.abbreviated).day())
  }

  /// "Thursday evening"
  func weekdayAndPartOfDay(of date: Date) -> String {
    let partOfDay = PartOfDay(hour: calendar.component(.hour, from: date))
    return "\(date.formatted(style.weekday(.wide))) \(partOfDay.rawValue)"
  }

  private var style: Date.FormatStyle {
    var style = Date.FormatStyle(date: .omitted, time: .omitted)
    style.calendar = calendar
    style.timeZone = calendar.timeZone
    style.locale = calendar.locale ?? .current
    return style
  }
}
