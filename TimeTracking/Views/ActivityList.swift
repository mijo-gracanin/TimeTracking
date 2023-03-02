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
            List(selection: viewStore.binding(get: \.selectedActivityByUuid,
                                              send: Activities.Action.selectActivityByUuid)) {
                ForEach(viewStore.activities) { activity in
#if os(macOS)
                    NavigationLink {
                        ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                            .padding()
                    } label:
                    {
                        ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                            .contextMenu {
                                Button("Delete") {
                                    guard let idx = viewStore.activities.firstIndex(of: activity) else { return }
                                    viewStore.send(.onDelete(IndexSet(integer: idx)))
                                }
                            }
                    }
#else
                    ActivityRow(store: Store(initialState: activity, reducer: Activity()))
#endif
                }
                .onDelete { indexSet in
                    viewStore.send(.onDelete(indexSet))
                }
            }
#if os(macOS)
            .onDeleteCommand(perform: viewStore.selectedActivityByUuid == nil ? nil : deleteSelected(viewStore: viewStore))
#endif
            .onAppear {
              viewStore.send(.onAppear)
            }
        }
    }
    
    private func deleteSelected(viewStore: ViewStore<Activities.State, Activities.Action>) -> (() -> ())  {
        return {
            guard let selected = viewStore.selectedActivityByUuid else { return }
            guard let idx = viewStore.activities.firstIndex(where: { $0.id == selected }) else { return }
            viewStore.send(.onDelete(IndexSet(integer: idx)))
        }
    }
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
