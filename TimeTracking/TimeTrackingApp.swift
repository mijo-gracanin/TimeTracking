//
//  TimeTrackingApp.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import SwiftUI
import ComposableArchitecture

@main
struct TimeTrackingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: Activities.State(),
                                     reducer: Activities()))
        }
    }
}
