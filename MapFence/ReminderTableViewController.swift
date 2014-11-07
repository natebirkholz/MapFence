//
//  ReminderTableViewController.swift
//  MapFence
//
//  Created by Nathan Birkholz on 11/4/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import CoreData


class ReminderTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var managedObjectContext : NSManagedObjectContext!
  var fetchedResultsController: NSFetchedResultsController!


    override func viewDidLoad() {
        super.viewDidLoad()

      let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
      self.managedObjectContext = appDelegate.managedObjectContext
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

  func didGetCloudChanges(notification : NSNotification) {
    self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
  }

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




} // End
