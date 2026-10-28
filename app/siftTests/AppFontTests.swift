import Testing
import UIKit

@testable import sift

/// `Font.custom` silently falls back to the system font when a name is wrong,
/// so check every bundled font resolves by name.
struct AppFontTests {
  @Test(arguments: AppFont.allCases)
  func fontResolvesByName(font: AppFont) {
    AppFont.registerAll()
    #expect(UIFont(name: font.rawValue, size: 12) != nil)
  }

  @Test func semiBoldIsHeavierThanRegular() throws {
    AppFont.registerAll()
    let regular = try #require(UIFont(name: AppFont.sans.rawValue, size: 20))
    let semiBold = try #require(UIFont(name: AppFont.sansSemiBold.rawValue, size: 20))
    let text = "Lorde at TD Garden" as NSString
    #expect(text.size(withAttributes: [.font: semiBold]).width > text.size(withAttributes: [.font: regular]).width)
  }
}
