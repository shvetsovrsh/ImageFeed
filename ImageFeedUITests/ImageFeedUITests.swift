//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ruslan S. Shvetsov on 27.08.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {

        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("abcde14@yandex.ru")
        webView.swipeUp()

        app.toolbars["Toolbar"].buttons["Done"].tap()
        print(app.toolbars["Toolbar"].buttons["Done"].exists)

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("12345678")
        webView.swipeUp()


        app.toolbars["Toolbar"].buttons["Done"].tap()
        print(app.toolbars["Toolbar"].buttons["Done"].exists)

        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let tablesQuery = app.tables

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()

        sleep(2)

        cellToLike.tap()

        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["loginNameLabel"].exists)

        app.buttons["logout button"].tap()
        app.alerts["Пока, Пока!"].scrollViews.otherElements.buttons["logoutAction"].tap()
    }
}
