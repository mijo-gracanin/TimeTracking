//
//  ActivitiesTests.swift
//  TimeTrackingTests
//
//  Created by Mijo Gracanin on 27.02.2023..
//

import XCTest
import ComposableArchitecture
@testable import TimeTracking

final class ActivitiesTests: XCTestCase {
    
    var date: Date!
    
    override func setUpWithError() throws {
        date = Date.distantPast
    }

    override func tearDownWithError() throws {
        date = nil
    }

    @MainActor
    func testOnAppear() async {
        let store = TestStore(
            initialState: Activities.State(),
            reducer: Activities()
        ) {
            $0.activityClient = .testValue
        }
        
        await store.send(.onAppear)
        
        await store.receive(.getAllActivities(.success(try! ActivityClient.testValue.all()))) {
            $0.activities = IdentifiedArrayOf(uniqueElements: try! ActivityClient.testValue.all())
        }
    }
    
    @MainActor
    func testAddActivity() async {
        let activities = IdentifiedArrayOf(uniqueElements: try! ActivityClient.testValue.all())
        let store = TestStore(
            initialState: Activities.State(activities: activities),
            reducer: Activities()
        ) {
            $0.activityClient = .testValue
            $0.date = .init { self.date }
        }
        
        let newActivity = Activity.State(start: self.date, end: self.date)

        await store.send(.addActivity(newActivity)) {
            $0.activities = activities + [newActivity]
        }
    }
    
    @MainActor
    func testOnDelete() async {
        var activities = IdentifiedArrayOf(uniqueElements: try! ActivityClient.testValue.all())
        let store = TestStore(
            initialState: Activities.State(activities: activities),
            reducer: Activities()
        ) {
            $0.activityClient = .testValue
        }
        
        
        let activity = activities.removeFirst()
        
        await store.send(.onDelete(IndexSet([0])))
        
        await store.receive(.activityRemoveResponse(.success(ActivityRemoveResponse(removedActivities: [activity], allActivities: activities.elements)))) {
            $0.activities = activities
        }
    }
    
    @MainActor
    func testSelectActivityByUuid() async {
        var activities = IdentifiedArrayOf(uniqueElements: try! ActivityClient.testValue.all())
        let store = TestStore(
            initialState: Activities.State(activities: activities),
            reducer: Activities()
        ) {
            $0.activityClient = .testValue
        }
        
        XCTAssertNil(store.state.selectedActivityByUuid)
        
        let uuid = store.state.activities.first!.id
        
        await store.send(.selectActivityByUuid(uuid)) {
            $0.selectedActivityByUuid = uuid
        }
    }

}
