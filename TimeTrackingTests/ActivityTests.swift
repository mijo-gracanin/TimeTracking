//
//  ActivityTests.swift
//  TimeTrackingTests
//
//  Created by Mijo Gracanin on 26.02.2023..
//

import XCTest
import ComposableArchitecture
@testable import TimeTracking

final class ActivityTests: XCTestCase {

    let clock = TestClock()
    var date: Date!
    
    override func setUpWithError() throws {
        date = Date.distantPast
    }

    override func tearDownWithError() throws {
        date = nil
    }
    
    @MainActor
    func testActivityStartedAndFinished() async {
        let store = TestStore(
            initialState: Activity.State(),
            reducer: Activity()
        ) {
            $0.suspendingClock = clock
            $0.date = .init { self.date }
            $0.uuid = .incrementing
        }
        
        
        await store.send(.activityStarted) {
            $0.start = self.date
            $0.end = self.date
        }
        
        date = date.addingTimeInterval(0.1)
        await clock.advance(by: .seconds(0.1))
        
        await store.receive(.clockTicked) {
            $0.end = self.date
        }
        
        await store.send(.activityFinished) {
            $0.start = nil
            $0.end = nil
        }
    }

    @MainActor
    func testTitleDidChange() async {
        // given
        let store = TestStore(
            initialState: Activity.State(),
            reducer: Activity()
        )
        
        
        // when
        await store.send(.titleDidChange("OK")) {
            // then
            $0.title = "OK"
        }
    }

    @MainActor
    func testClockTicked() async {
        // given
        let store = TestStore(
            initialState: Activity.State(end: date),
            reducer: Activity()
        ) {
            $0.date = .init { self.date }
        }
        
        // when
        date = date.addingTimeInterval(0.1)
        await store.send(.clockTicked) {
            // then
            $0.end = self.date
        }
    }
}
