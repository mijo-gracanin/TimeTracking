//
//  Activity+CoreDataClass.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 26.02.2023..
//
//

import Foundation
import CoreData


public class Activity: NSManagedObject {
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

extension Activity : Identifiable {

}
