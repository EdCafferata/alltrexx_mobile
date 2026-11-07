import XCTest

/// Rook-test: start de app en controleer dat hij de voorgrond haalt zonder te crashen.
/// Dit vangt precies de klasse fouten die je anders pas bij een release merkt
/// (crash bij opstart tegen een nieuwere SDK).
final class SmokeUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testAppLaunchesWithoutCrashing() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 15),
            "App bereikte de voorgrond niet binnen 15s — waarschijnlijk een crash bij opstart"
        )
    }
}
