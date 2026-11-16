import Foundation

extension String {
  /// "1 photo", "7 photos". Foundation picks the right plural for the language.
  static func counted(_ count: Int, _ noun: String) -> String {
    String(AttributedString(localized: "^[\(count) \(noun)](inflect: true)").characters)
  }
}
