//
//  ActivityCreatorTests.swift
//  TimeTrackingTests
//
//  Created by Mijo Gracanin on 26.02.2023..
//

import XCTest
import CoreData
@testable import TimeTracking

final class ActivityCreatorTests: XCTestCase {

    var sut: ActivityCreator.ViewModel!
    
    override func setUpWithError() throws {
        sut = ActivityCreator.ViewModel()
        sut.viewContext = PersistenceController(inMemory: true).container.viewContext
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_ViewModel_StartTimeTracking_ActivityCountSame() throws {
        // given
        let request = NSFetchRequest<Activity>(entityName: "Activity")
        XCTAssertEqual(try sut.viewContext?.count(for: request), 0)
        
        
        // when
        sut.toggleTimer()
        
        
        // then
        XCTAssertEqual(try! sut.viewContext?.count(for: request), 0)
    }

    func test_ViewModel_StopTimeTracking_ActivityAdded() throws {
        // given
        let request = NSFetchRequest<Activity>(entityName: "Activity")
        XCTAssertEqual(try sut.viewContext?.count(for: request), 0)
        
        
        // when
        sut.toggleTimer() // start
        sut.toggleTimer() // stop
        
        
        // then
        XCTAssertEqual(try! sut.viewContext?.count(for: request), 1)
    }
}
