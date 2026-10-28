import CoreText
import SwiftUI

/// The bundled typefaces, by PostScript name. Files live in `Resources/Fonts/`.
nonisolated enum AppFont: String, CaseIterable {
  case serif = "InstrumentSerif-Regular"
  case serifItalic = "InstrumentSerif-Italic"
  case sans = "Manrope-Regular"
  case sansSemiBold = "Manrope-SemiBold"
  case mono = "DMMono-Regular"

  /// Both Manrope weights come from one variable font file.
  var fileName: String {
    switch self {
    case .sans, .sansSemiBold: "Manrope-Variable"
    default: rawValue
    }
  }

  /// Registers the font files with the system so `Font.custom` can find them.
  /// Runs once, the first time a font is used, so it also works in previews.
  static func registerAll() {
    _ = registration
  }

  private static let registration: Void = {
    for fileName in Set(allCases.map(\.fileName)) {
      guard let url = Bundle.main.url(forResource: fileName, withExtension: "ttf") else {
        assertionFailure("Missing font file \(fileName).ttf")
        continue
      }
      CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
  }()
}

/// The type scale. Sizes scale with Dynamic Type.
extension Font {
  /// Screen titles.
  static var displayLarge: Font { app(.serif, 44, .largeTitle) }
  /// Moment titles on detail screens.
  static var display: Font { app(.serif, 32, .title) }
  /// Card titles, section headings.
  static var heading: Font { app(.serif, 24, .title2) }
  /// Captions, stickers, the small "cute" touches.
  static var headingItalic: Font { app(.serifItalic, 20, .title3) }
  static var bodyText: Font { app(.sans, 15, .body) }
  static var bodyEmphasis: Font { app(.sansSemiBold, 15, .body) }
  /// Buttons, chips, tab labels.
  static var label: Font { app(.sansSemiBold, 13, .subheadline) }
  /// Secondary text under titles.
  static var note: Font { app(.sans, 12, .footnote) }
  /// Timestamps, coordinates, counts.
  static var mono: Font { app(.mono, 11, .caption) }

  private static func app(_ font: AppFont, _ size: CGFloat, _ style: TextStyle) -> Font {
    AppFont.registerAll()
    return .custom(font.rawValue, size: size, relativeTo: style)
  }
}
