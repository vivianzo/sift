import SwiftUI

/// Bundled typefaces by PostScript name. The files are listed in `Info.plist` under `UIAppFonts`.
enum AppFont: String, CaseIterable {
  case serif = "InstrumentSerif-Regular"
  case serifItalic = "InstrumentSerif-Italic"
  case sans = "Manrope-Regular"
  case sansSemiBold = "Manrope-SemiBold"
  case mono = "DMMono-Regular"
}

/// The type scale. Sizes scale with Dynamic Type.
extension Font {
  static var displayLarge: Font { app(.serif, 44, .largeTitle) }
  static var display: Font { app(.serif, 32, .title) }
  static var heading: Font { app(.serif, 24, .title2) }
  static var headingItalic: Font { app(.serifItalic, 20, .title3) }
  static var bodyText: Font { app(.sans, 15, .body) }
  static var bodyEmphasis: Font { app(.sansSemiBold, 15, .body) }
  static var label: Font { app(.sansSemiBold, 13, .subheadline) }
  static var note: Font { app(.sans, 12, .footnote) }
  static var mono: Font { app(.mono, 11, .caption) }

  private static func app(_ font: AppFont, _ size: CGFloat, _ style: TextStyle) -> Font {
    .custom(font.rawValue, size: size, relativeTo: style)
  }
}
