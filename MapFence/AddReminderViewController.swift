//
//  AddReminderViewController.swift
//  MapFence
//
//  Created by Nathan Birkholz on 11/4/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class AddReminderViewController: UIViewController {

  var managedObjectContext : NSManagedObjectContext!

  var locationManager : CLLocationManager!
  var selectedAnnotation : MKAnnotation!


    override func viewDidLoad() {
        super.viewDidLoad()

      let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
      self.managedObjectContext = appDelegate.managedObjectContext

      let regionSet = self.locationManager.monitoredRegions
      let regions = regionSet.allObjects


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func clickedButton(sender: AnyObject) {
    let idString = "Reminder: "
    let radius = 5000.0
    let date = NSDate()
    let identifier = idString + String(date.description)
      println("identifier is \(identifier)")
    var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: radius, identifier: identifier)

    self.locationManager.startMonitoringForRegion(geoRegion)
    NSNotificationCenter.defaultCenter().postNotificationName("ADDED_REMINDER", object: self, userInfo: ["region": geoRegion, "annotation" : selectedAnnotation, "title" : identifier])

    var reminderFor = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.managedObjectContext) as Reminder
    let coordinateFor = self.selectedAnnotation.coordinate
    let latFor = coordinateFor.latitude as Double
    let lonFor = coordinateFor.latitude as Double
    reminderFor.reminderName = identifier
    reminderFor.reminderRadius = radius
    reminderFor.reminderDate = date
    reminderFor.reminderLat = latFor
    reminderFor.reminderLon = lonFor

    var error : NSError?
    self.managedObjectContext.save(&error)
    if error != nil {
      println(error?.localizedDescription)
    }

    self.dismissViewControllerAnimated(true, completion: nil)

  }



}
