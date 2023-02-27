//
//  Persistence.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for idx in 1...3 {
            let newActivity = ActivityMO(context: viewContext)
            newActivity.id = UUID(uuidString: "00000000-0000-0000-0000-00000000000\(idx)")
            newActivity.start = Date()
            newActivity.end = Date().addingTimeInterval(TimeInterval(idx))
            newActivity.title = "Task #\(idx)"
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TimeTracking")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func getActivityStates() throws -> [Activity.State] {
        let activityStates = try getActivityMOs().map { Activity.State(with: $0) }
        return activityStates
    }
    
    func addActivity(_ activity: Activity.State) throws -> ActivityAddResponse {
        
        let activityMO = ActivityMO.instance(from: activity, with: context)
        
        try context.save()
        
        return ActivityAddResponse(addedActivity: Activity.State(with: activityMO),
                                   allActivities: try getActivityStates())
    }
    
    func removeActivities(_ activities: [Activity.State]) throws -> ActivityRemoveResponse {
        
        var removedActivities: [Activity.State] = []
        
        try activities.forEach { activity in
            let activityMOs = try getActivityMOs()
            if let itemId = activityMOs.filter({ $0.id == activity.id }).first?.objectID,
               let activityMO = context.object(with: itemId) as? ActivityMO {
                context.delete(activityMO)
                removedActivities.append(activity)
            }
        }
        try context.save()
        
        return ActivityRemoveResponse(removedActivities: removedActivities,
                                      allActivities: try getActivityStates())
    }
    
    // MARK: - Private
    private func getActivityMOs() throws -> [ActivityMO] {
        let request = NSFetchRequest<ActivityMO>(entityName: "Activity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ActivityMO.start, ascending: true)]
        let activityMOs = try context.fetch(request)
        
        return activityMOs
    }
    
    private var context: NSManagedObjectContext {
        return container.viewContext
    }
}
