//
//  Created by martin on 21.04.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import XCTest

class IcroScreenshotsTests: XCTestCase {
    static let accessToken = "ACCESS_TOKEN_REPLACE"

    override func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testScreenshots() {
        let app = XCUIApplication()

        if app.buttons["Login with access token"].exists {
            login()
        }

        sleep(15)
        snapshot("01Timeline")

        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Discover"].tap()
        sleep(15)
        snapshot("02Discover")
        tabBarsQuery.buttons["Profile"].tap()
        sleep(15)
        snapshot("03Profile")
    }

    func login() {
        let app = XCUIApplication()
        let mailAddressOrAccessTokenTextField = app.textFields["Mail address or access token"]
        mailAddressOrAccessTokenTextField.tap()
        mailAddressOrAccessTokenTextField.typeText(IcroScreenshotsTests.accessToken)
        app.buttons["Login with access token"].tap()
    }
}
