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
            List {
                ForEach(viewStore.activities) { activity in
                    ActivityRow(store: Store(initialState: activity, reducer: Activity()))
                }
                .onDelete { indexSet in
                    viewStore.send(.onDelete(indexSet))
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
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
