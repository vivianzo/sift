import XCTest

/// Walks the real permission prompt. The simulator's `simctl privacy grant photos`
/// doesn't set read-write access, so this is the reliable way to check the flow.
final class PhotoAccessUITests: XCTestCase {
  private let app = XCUIApplication()
  private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

  override func setUp() {
    continueAfterFailure = false
    app.resetAuthorizationStatus(for: .photos)
  }

  @MainActor
  func testAllowingFullAccessShowsTheTabs() {
    app.launch()
    app.buttons["Allow photo access"].tap()
    tapAlertButton(containing: "Full Access")
    XCTAssertTrue(app.tabBars.buttons["Moments"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["Allow all"].exists)
  }

  @MainActor
  func testDenyingAccessShowsTheSettingsScreen() {
    app.launch()
    app.buttons["Allow photo access"].tap()
    tapAlertButton(containing: "Don")
    XCTAssertTrue(app.staticTexts["Photo access is off"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Open Settings"].exists)
  }

  @MainActor
  func testLimitedAccessShowsTheBanner() {
    app.launch()
    app.buttons["Allow photo access"].tap()
    tapAlertButton(containing: "Limit")
    // iOS then shows its photo picker. Finish it without changing the selection.
    let done = app.buttons.matching(NSPredicate(format: "label IN %@", ["Done", "Continue"])).firstMatch
    if done.waitForExistence(timeout: 5) { done.tap() }
    XCTAssertTrue(app.buttons["Allow all"].waitForExistence(timeout: 5))
  }

  private func tapAlertButton(containing text: String) {
    let button = springboard.alerts.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    XCTAssertTrue(button.waitForExistence(timeout: 5), "No permission prompt button containing \"\(text)\"")
    button.tap()
  }
}
