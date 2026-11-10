//
//  Created by martin on 21.04.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import XCTest

class IcroScreenshotsTests: XCTestCase {
    func testScreenshots() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let tabBar = app.tabBars.firstMatch
        let timeline = tabBar.buttons["Timeline"]
        XCTAssertTrue(timeline.waitForExistence(timeout: 10))
        timeline.tap()
        XCTAssertFalse(app.buttons["Log In"].exists, "Sign in to Micro.blog on this simulator before running Screenshots.")

        sleep(15)
        attachScreenshot(named: "01Timeline")

        tabBar.buttons["Discover"].tap()
        sleep(15)
        attachScreenshot(named: "02Discover")

        tabBar.buttons["Profile"].tap()
        sleep(15)
        attachScreenshot(named: "03Profile")
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
