//
//  ExtensionTests.swift
//  TimeTrackingTests
//
//  Created by Mijo Gracanin on 26.02.2023..
//

import XCTest
@testable import TimeTracking

final class ExtensionTests: XCTestCase {

    func testTimeIntervalToTimerString() throws {
        XCTAssertEqual(TimeInterval(0).toTimerString(), "00:00")
        XCTAssertEqual(TimeInterval(1).toTimerString(), "00:01")
        XCTAssertEqual(TimeInterval(42.9).toTimerString(), "00:42")
        XCTAssertEqual(TimeInterval(61).toTimerString(), "01:01")
        XCTAssertEqual(TimeInterval(3661).toTimerString(), "01:01:01")
    }
}
