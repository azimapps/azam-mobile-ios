//
//  AwaitrUITests.swift
//  AwaitrUITests
//
//  Created by ZoldyckD on 20/03/26.
//

import XCTest

final class AwaitrUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--skip-onboarding")
        app.launch()
    }

}
