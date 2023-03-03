//
//  ActivityList.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import SwiftUI
import ComposableArchitecture

struct ActivityList: View {    
    let store: StoreOf<Activities>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
#if os(macOS)
            MacList(viewStore: viewStore)
#else
            IosList(viewStore: viewStore)
#endif
        }
    }
    
    private struct IosList: View {
        let viewStore: ViewStore<Activities.State, Activities.Action>
        
        var body: some View {
            List {
                ForEach(viewStore.activities) { activity in
                    ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                }
                .onDelete { viewStore.send(.onDelete($0)) }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
    
#if os(macOS)
    private struct MacList: View {
        let viewStore: ViewStore<Activities.State, Activities.Action>
        
        var body: some View {
            List(selection: viewStore.binding(get: \.selectedActivityByUuid,
                                              send: Activities.Action.selectActivityByUuid)) {
                ForEach(viewStore.activities) { activity in
                    NavigationLink {
                        ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                            .padding()
                    } label: {
                        ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                            .contextMenu {
                                Button("Delete") {
                                    viewStore.send(.deleteActivity(activity))
                                }
                            }
                    }
                }
            }
            .onDeleteCommand(perform: viewStore.selectedActivityByUuid == nil ? nil : { viewStore.send(.deleteSelected) })
            .onAppear { viewStore.send(.onAppear) }
        }
    }
#endif
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityList(store: Store(
            initialState: Activities.State(
                activities: IdentifiedArrayOf(
                    uniqueElements: try! PersistenceController.preview.getActivityStates())),
            reducer: Activities()))
    }
}
