//
//  ActivityMO+CoreDataClass.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 26.02.2023..
//
//

import Foundation
import CoreData


public class ActivityMO: NSManagedObject {
    @NSManaged var end: Date
    @NSManaged var start: Date
    @NSManaged var title: String
    
    @objc var sectionTitle: String {
        return DateFormatter.localizedString(from: start, dateStyle: .medium, timeStyle: .none)
    }
    
    @objc var duration: String {
        return DateFormatter.localizedString(from: start, dateStyle: .none, timeStyle: .short)
    }
}

extension ActivityMO : Identifiable {
    @NSManaged public var id: UUID?
}

extension ActivityMO {
    static func instance(from activity: Activity.State, with context: NSManagedObjectContext) -> ActivityMO {
        let newActivityMO = ActivityMO(context: context)
        newActivityMO.id = activity.id
        newActivityMO.title = activity.title
        newActivityMO.start = activity.start!
        newActivityMO.end = activity.end!
        
        return newActivityMO
    }
}
