//
//  ActivityClient.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 27.02.2023..
//

import ComposableArchitecture

struct ActivityClient {
    var all: () throws -> [Activity.State]
    var add: (_ activity: Activity.State) throws -> ActivityAddResponse
    var remove: (_ activities: [Activity.State]) throws -> ActivityRemoveResponse
}

extension ActivityClient: DependencyKey {
    
    // MARK: - Live
    static let liveValue = Self(
        all: {
            try PersistenceController.shared.getActivityStates()
        },
        add: { activity in
            try PersistenceController.shared.addActivity(activity)
        },
        remove: { activities in
            try PersistenceController.shared.removeActivities(activities)
        }
    )
    
    // MARK: - Test
    static let testValue = Self(
        all: {
            try PersistenceController.preview.getActivityStates()
        },
        add: { activity in
            try PersistenceController.preview.addActivity(activity)
        },
        remove: { activities in
            try PersistenceController.preview.removeActivities(activities)
        }
    )
}

extension DependencyValues {
    var activityClient: ActivityClient {
        get { self[ActivityClient.self] }
        set { self[ActivityClient.self] = newValue }
    }
}

// MARK: - Response
struct ActivityAddResponse: Equatable {
    let addedActivity: Activity.State
    let allActivities: [Activity.State]
}

struct ActivityRemoveResponse: Equatable {
    let removedActivities: [Activity.State]
    let allActivities: [Activity.State]
}
