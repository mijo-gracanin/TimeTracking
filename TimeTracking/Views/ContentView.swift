//
//  ContentView.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

    let store: StoreOf<Activities>
    
    var body: some View {
        NavigationView {
            VStack {
                ActivityList(store: store)
                Spacer()
                ActivityCreator(store: Store(initialState: Activity.State(), reducer: Activity()),
                                activitiesViewStore: ViewStore(store.stateless))
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: Activities.State(
            activities: IdentifiedArrayOf(
                uniqueElements: try! PersistenceController.preview.getActivityStates())),
                                 reducer: Activities()))
    }
}
