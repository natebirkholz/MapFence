//
//  Reminder.swift
//  MapFence
//
//  Created by Nathan Birkholz on 11/5/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var reminderName: String
    @NSManaged var reminderDate: NSDate
    @NSManaged var reminderRadius: NSNumber
    @NSManaged var reminderLat: Double
    @NSManaged var reminderLon: Double
} // End
