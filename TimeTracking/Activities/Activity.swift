//
//  Activity.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 27.02.2023..
//

import Foundation
import ComposableArchitecture

struct Activity: ReducerProtocol {
    
    struct State: Equatable, Identifiable, Hashable {
        var title = ""
        var id: UUID
        var start: Date?
        var end: Date?
        
        init(with activityMO: ActivityMO) {
            title = activityMO.title
            id = activityMO.id ?? UUID()
            start = activityMO.start
            end = activityMO.end
        }
        
        init(title: String = "",
             id: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
             start: Date? = nil,
             end: Date? = nil) {
            self.title = title
            self.id = id
            self.start = start
            self.end = end
        }
    }
    
    enum Action: Equatable {
        case activityStarted
        case titleDidChange(String)
        case activityFinished
        case clockTicked
    }
    
    @Dependency(\.suspendingClock) var clock
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    
    private enum ActivityCompletionId {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .activityStarted:
            state.id = uuid()
            state.start = date.now
            state.end = date.now
            return .run { send in
                while true {
                    try await self.clock.sleep(for: .milliseconds(100))
                    await send(.clockTicked)
                }
            }
            .cancellable(id: ActivityCompletionId.self, cancelInFlight: true)
            
        case .titleDidChange(let title):
            state.title = title
            return .none
            
        case .activityFinished:
            state.start = nil
            state.end = nil
            return .cancel(id: ActivityCompletionId.self)
            
        case .clockTicked:
            state.end = date.now
            return .none
        }
    }
}
