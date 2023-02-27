//
//  Activities.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 27.02.2023..
//

import Foundation
import ComposableArchitecture

struct Activities: ReducerProtocol {
    struct State: Equatable {
        var activities: IdentifiedArrayOf<Activity.State> = []
        var templateActivity = Activity.State()
    }
    
    enum Action: Equatable {
        case onAppear
        case addActivity(Activity.State)
        case onDelete(IndexSet)
        case getAllActivities(TaskResult<[Activity.State]>)
        case activityRemoveResponse(TaskResult<ActivityRemoveResponse>)
    }
    
    @Dependency(\.activityClient) var activityClient
    @Dependency(\.date) var date
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task {
                await .getAllActivities(
                    TaskResult {
                        try activityClient.all()
                    })
            }
            
        case .addActivity(var activity):
            do {
                activity.end = date.now
                let response = try activityClient.add(activity)
                state.activities.append(response.addedActivity)
            } catch {
                // TODO: Handle error
            }
            
            return .none
            
            
        case .onDelete(let indexSet):
            var activities: [Activity.State] = []
            
            for index in indexSet {
                activities.append(state.activities[index])
            }
            
            let activitiestToRemove = activities
            
            return .task {
                await .activityRemoveResponse(
                    TaskResult {
                        try activityClient.remove(activitiestToRemove)
                    })
            }
            
        case .getAllActivities(.success(let activities)):
            state.activities = IdentifiedArrayOf(uniqueElements: activities)
            return .none
            
        case .activityRemoveResponse(.success(let response)):
            let removedIds = response.removedActivities.map { $0.id }
            removedIds.forEach { id in
                state.activities.remove(id: id)
            }
            return .none
            
        case .getAllActivities(.failure), .activityRemoveResponse(.failure):
            // TODO: - Error Handling
            return .none
        }
    }
}
