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
        var selectedActivityByUuid: UUID?
    }
    
    enum Action: Equatable {
        case onAppear
        case addActivity(Activity.State)
        case onDelete(IndexSet)
        case getAllActivities(TaskResult<[Activity.State]>)
        case activityAddResponse(TaskResult<ActivityAddResponse>)
        case activityRemoveResponse(TaskResult<ActivityRemoveResponse>)
        case selectActivityByUuid(UUID?)
        case deleteSelected
        case deleteActivity(Activity.State)
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
            activity.end = date.now
            let activityToAdd = activity
            
            return .task {
                await .activityAddResponse(
                    TaskResult {
                        try activityClient.add(activityToAdd)
                    })
            }
        
        case .activityAddResponse(.success(let response)):
            state.activities = IdentifiedArrayOf(uniqueElements: response.allActivities)
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
            
        case .deleteSelected:
            guard let uuid = state.selectedActivityByUuid,
                  let activity = state.activities.first(where: { $0.id == uuid }) else {
                return .none
            }
            return .task {
                await .activityRemoveResponse(
                    TaskResult {
                        try activityClient.remove([activity])
                    })
            }
            
        case .deleteActivity(let activity):
            return .task {
                await .activityRemoveResponse(
                    TaskResult {
                        try activityClient.remove([activity])
                    })
            }
            
        case .getAllActivities(.success(let activities)):
            state.activities = IdentifiedArrayOf(uniqueElements: activities)
            return .none
            
        case .activityRemoveResponse(.success(let response)):
            let removedIds = response.removedActivities.map { $0.id }
            removedIds.forEach { id in
                state.activities.remove(id: id)
                if let uuid = state.selectedActivityByUuid, uuid == id {
                    state.selectedActivityByUuid = nil
                }
            }
            return .none
            
        case .selectActivityByUuid(let uuid):
            state.selectedActivityByUuid = uuid
            return .none
            
        case .getAllActivities(.failure), .activityAddResponse(.failure), .activityRemoveResponse(.failure):
            // TODO: - Error Handling
            return .none
        }
    }
}
