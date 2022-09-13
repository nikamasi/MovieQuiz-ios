//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Niki Masi on 10.09.2022.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        let firstPoster = app.images["Poster"]
        app.buttons["Yes"].tap()
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testNoButton() throws {
        let firstPoster = app.images["Poster"]
        app.buttons["No"].tap()
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }

    func testAlert() throws {
        let yesButton = app.buttons[
            "Yes"
        ]
        sleep(3)
        for _ in 1...10 {
            yesButton.tap()
            sleep(3)
        }
        let alert = app.alerts["results"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
        sleep(2)
        alert.buttons.firstMatch.tap()
        XCTAssertFalse(alert.exists)
        sleep(2)
        XCTAssertTrue(app.staticTexts["Index"].label == "1/10")
    }
}
