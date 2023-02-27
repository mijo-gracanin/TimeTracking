//
//  ActivityCreator.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 24.02.2023..
//

import SwiftUI
import ComposableArchitecture

struct ActivityCreator: View {
    let store: StoreOf<Activity>
    @ObservedObject var activitiesViewStore: ViewStore<Void, Activities.Action>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                VStack {
                    TextField("I'm working on...", text: viewStore.binding(get: \.title,
                                                                           send: Activity.Action.titleDidChange))
                    Text("\(getTimerString(activity: viewStore.state))")
                        .frame(height: 21)
                }
                Button {
                    if viewStore.start == nil {
                        viewStore.send(.activityStarted)
                    } else {
                        activitiesViewStore.send(.addActivity(viewStore.state))
                        viewStore.send(.activityFinished)
                    }
                } label: {
                    Image(systemName: viewStore.start == nil ? "play.circle" : "stop.circle")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .foregroundColor(viewStore.start == nil ? .purple : .orange)
                }
            }
        }
    }
    
    private func getTimerString(activity: Activity.State) -> String {
        guard let start = activity.start else {
            return ""
        }
        return Date().timeIntervalSince(start).toTimerString()
    }
}


struct ActivityCreator_Previews: PreviewProvider {
    static let store = Store(
        initialState: Activity.State(id: UUID()),
        reducer: Activity())
    
    static let activitiesStore = Store(
        initialState: Activities.State(
            activities: IdentifiedArrayOf(
                uniqueElements: try! PersistenceController.preview.getActivityStates())),
        reducer: Activities())
    
    static var previews: some View {
        ActivityCreator(store: store,
                        activitiesViewStore: ViewStore(activitiesStore.stateless))
    }
}
