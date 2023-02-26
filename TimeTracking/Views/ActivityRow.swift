//
//  ActivityRow.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 25.02.2023..
//

import SwiftUI
import CoreData

struct ActivityRow: View {
    var activity: Activity
    var body: some View {
        VStack {
            HStack {
                Text(activity.title)
                Spacer()
                Text("Total: \(totalTime)")
            }
            HStack {
                Text("Start: \(activity.start, formatter: timeOnlyFormatter)")
                Spacer()
                Text("End: \(activity.end, formatter: timeOnlyFormatter)")
            }
        }
    }
    
    private var totalTime: String {
        return activity.end.timeIntervalSince(activity.start).toTimerString()
    }
}

private let timeOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct ActivityRowView_Previews: PreviewProvider {
    static var fetchRequest: NSFetchRequest<Activity> {
        let request = NSFetchRequest<Activity>(entityName: "Activity")
        request.fetchLimit = 1
        return request
    }
    
    static var activity: Activity {
        return try! PersistenceController.preview.container.viewContext.fetch(fetchRequest)[0]
    }
    
    static var previews: some View {
        ActivityRow(activity: activity)
            .previewLayout(.sizeThatFits)
    }
}
