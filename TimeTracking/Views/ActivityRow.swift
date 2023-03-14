//
//  ActivityRow.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 25.02.2023..
//

import SwiftUI
import ComposableArchitecture

struct ActivityRow: View {
    let store: StoreOf<Activity>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Text(viewStore.title)
                    Spacer()
                    Text("Total: \(getTotalTime(activity: viewStore.state))")
                }
                HStack {
                    Text("Start: \(viewStore.start!, formatter: timeOnlyFormatter)")
                    Spacer()
                    Text("End: \(viewStore.end!, formatter: timeOnlyFormatter)")
                }
            }
        }
    }
    
    private func getTotalTime(activity: Activity.State) -> String {
        return activity.end!.timeIntervalSince(activity.start!).toTimerString()
    }
}

private let timeOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRow(store: .init(initialState: .init(
            title: "The Task",
            id: UUID(),
            start: Date(),
            end: Date().addingTimeInterval(55)),
                                 reducer: Activity()))
        .previewLayout(.sizeThatFits)
    }
}
