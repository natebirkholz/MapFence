//
//  ReminderTableViewController.swift
//  MapFence
//
//  Created by Nathan Birkholz on 11/4/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit


class ReminderTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

/////////////////////////////////
// MARK: Properties
/////////////////////////////////

  @IBOutlet weak var tableView: UITableView!

  var managedObjectContext : NSManagedObjectContext!
  var fetchedResultsController: NSFetchedResultsController!
  var locationManager : CLLocationManager!

/////////////////////////////////
// MARK: Lifecycle
/////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()


      let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
      self.managedObjectContext = appDelegate.managedObjectContext
      self.locationManager = appDelegate.locationManager
      self.tableView.dataSource = self
      self.tableView.delegate = self

      NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetCloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: appDelegate.persistentStoreCoordinator)

      var fetchRequest = NSFetchRequest(entityName: "Reminder")
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "reminderDate", ascending: true)]

      self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "RemindersCache")
      self.fetchedResultsController.delegate = self

      var error : NSError?
      if !self.fetchedResultsController.performFetch(&error) {
        println("error!!")
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

/////////////////////////////////
// MARK: Observers
/////////////////////////////////

  func didGetCloudChanges(notification : NSNotification) {
    self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
  }

/////////////////////////////////
// MARK: TableView
/////////////////////////////////

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.fetchedResultsController.fetchedObjects?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL", forIndexPath: indexPath) as UITableViewCell
    let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder

    cell.textLabel.text = reminder.reminderName

    return cell
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.reloadData()
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
    var coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(reminder.reminderLat), CLLocationDegrees(reminder.reminderLon))
    var radius = CLLocationDistance(reminder.reminderRadius)
    var identifier = reminder.reminderName as String!

    var selectedAnnotation = MKPointAnnotation()
    selectedAnnotation.coordinate = coordinate
    println(selectedAnnotation)
    println(selectedAnnotation.coordinate.latitude)
    var geoRegion = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)

    self.locationManager.startMonitoringForRegion(geoRegion)

    var tabBarController = self.tabBarController as TabBarController
    println("this is \(tabBarController.viewControllers?.first?.description)")
    var destinationVC = tabBarController.viewControllers?.first as ViewController

    NSNotificationCenter.defaultCenter().postNotificationName("SELECTED_REMINDER", object: self, userInfo: ["region": geoRegion, "annotation" : selectedAnnotation, "title" : identifier])
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      self.managedObjectContext.deleteObject(self.fetchedResultsController.fetchedObjects![indexPath.row] as Reminder)
      var error : NSError?
      self.managedObjectContext.save(&error)}
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    switch type {
    case .Delete:
      self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
    default:
      println("hiya")
    }
  }

} // End
