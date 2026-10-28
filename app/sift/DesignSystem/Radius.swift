import CoreGraphics

/// Corner radii. Kept small on purpose; see `docs/design.md`.
enum Radius {
  /// Chips, thumbnails.
  static let small: CGFloat = 3
  /// Buttons, photos.
  static let medium: CGFloat = 6
  /// Cards.
  static let large: CGFloat = 10
}
