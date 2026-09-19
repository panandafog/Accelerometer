// Each method captures one screen and can be selected independently in FramePilot.
import XCTest

final class StoreScreenshots: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testScreen01_home() throws {
        let app = launchApp()
        try capture("home", app: app, readyID: "screen.home")
    }

    func testScreen02_settings() throws {
        let app = launchApp()
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()
        try capture("settings", app: app, readyID: "screen.settings")
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        return app
    }

    private func capture(_ name: String, app: XCUIApplication, readyID: String) throws {
        let ready = app.descendants(matching: .any).matching(identifier: readyID).firstMatch
        guard ready.waitForExistence(timeout: 30) else {
            XCTFail("Screen not ready: " + readyID)
            throw NSError(domain: "FramePilot.ScreenNotReady", code: 1)
        }
        #if os(macOS)
        // Set the window size in your app/test to match the required export dimensions.
        let screenshot = app.windows.firstMatch.screenshot()
        #else
        let screenshot = XCUIScreen.main.screenshot()
        #endif
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "framepilot-" + name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
