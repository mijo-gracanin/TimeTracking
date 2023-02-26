//
//  ActivityList.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import SwiftUI

struct ActivityList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, Activity>(
        sectionIdentifier: \.sectionTitle,
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.start, ascending: true)],
        animation: .default)
    private var activitySections: SectionedFetchResults<String, Activity>
    
    var body: some View {
        List {
            ForEach(activitySections) { section in
                Section(section.first!.sectionTitle) {
                    ForEach(section) { activity in
                        ActivityRow(activity: activity)
                    }
                    .onDelete { indexSet in
                        deleteActivities(section: section, offsets: indexSet)
                    }
                }
            }
        }

    }

    private func deleteActivities(section: SectionedFetchResults<String, Activity>.Section, offsets: IndexSet) {
        withAnimation {
            offsets.map { section[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityList().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
