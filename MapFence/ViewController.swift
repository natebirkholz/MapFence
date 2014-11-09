//
//  ViewController.swift
//  MapFence
//
//  Created by Nathan Birkholz on 11/3/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

/////////////////////////////////
// MARK: Properties
/////////////////////////////////

  let locationManager = CLLocationManager()

  @IBOutlet weak var mapView: MKMapView!

/////////////////////////////////
// MARK: Lifecycle
/////////////////////////////////

  override func viewDidLoad() {
    super.viewDidLoad()

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    appDelegate.locationManager = self.locationManager
    self.mapView.delegate = self
    self.locationManager.delegate = self

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedReminder:", name: "ADDED_REMINDER", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedReminder:", name: "SELECTED_REMINDER", object: nil)

    let longPress = UILongPressGestureRecognizer(target: self, action: "didPressLong:")
    self.mapView.addGestureRecognizer(longPress)
    self.mapView.delegate = self

    switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
    case .Authorized:
      println("Authorized status for CLLocationManager.")
      self.mapView.showsUserLocation = true
    case .AuthorizedWhenInUse:
      println("AuthorizedWhenInUse status for CLLocationManager.")
    case .Denied:
      println("Denied status for CLLocationManager.")
    case .NotDetermined:
      println("NotDetermined status for CLLocationManager.")
      self.locationManager.requestAlwaysAuthorization()
    case .Restricted:
      println("Restricted status for CLLocationManager.")
    default:
      println("authorization status not found for CLLocationManager.")
    }
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

/////////////////////////////////
// MARK: Observers
/////////////////////////////////

  func addedReminder(notification: NSNotification) {
    println("added reminder")
    let userInfo = notification.userInfo!
    let geoRegion = userInfo["region"] as CLCircularRegion

    let annotation = userInfo["annotation"] as MKPointAnnotation
    let title = userInfo["title"] as String
    annotation.title = title


    let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
    self.mapView.addOverlay(overlay)
  }

  func selectedReminder(notification: NSNotification) {
    println("selected reminder")
    let userInfo = notification.userInfo!
    let geoRegion = userInfo["region"] as CLCircularRegion

    let annotation = userInfo["annotation"] as MKPointAnnotation
    let title = userInfo["title"] as String
    annotation.title = title


    let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
    self.mapView.addOverlay(overlay)
  }

/////////////////////////////////
// MARK: MapView
/////////////////////////////////

  func didPressLong(sender: UILongPressGestureRecognizer) {

    if sender.state == UIGestureRecognizerState.Began {
      let touchPoint = sender.locationInView(self.mapView)
      let touchCoordinateFor = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
      println("lat: \(touchCoordinateFor.latitude), long: \(touchCoordinateFor.longitude)")
      var annotationFor = MKPointAnnotation()
      annotationFor.coordinate = touchCoordinateFor
      annotationFor.title = "Add Reminder"
      self.mapView.addAnnotation(annotationFor)
    }
  }

  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ANNOTATION")
    annotationView.animatesDrop = true
    annotationView.canShowCallout = true
    let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
    annotationView.rightCalloutAccessoryView = addButton

    return annotationView
  }

  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    let reminderVC = self.storyboard?.instantiateViewControllerWithIdentifier("REMINDER_VC") as AddReminderViewController
    reminderVC.locationManager = self.locationManager
    reminderVC.selectedAnnotation = view.annotation
    self.presentViewController(reminderVC, animated: true, completion: nil)
  }

  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    let renderer = MKCircleRenderer(overlay: overlay)
    renderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
    renderer.lineWidth = 1.0
    renderer.strokeColor = UIColor.cyanColor()
    renderer.lineDashPattern = [5, 7]
    return renderer
  }


/////////////////////////////////
// MARK: LocationManager
/////////////////////////////////


  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .Authorized:
      println("Case authorized for didChangeAuthorizationStatus")
    case .AuthorizedWhenInUse:
      println("Case AuthorizedWhenInUse for didChangeAuthorizationStatus")
    case .Denied:
      println("Case Denied for didChangeAuthorizationStatus")
    case .NotDetermined:
      println("Case NotDetermined for didChangeAuthorizationStatus")
    case .Restricted:
      println("Case Restricted for didChangeAuthorizationStatus")
    default:
      println("Dfeault case for didChangeAuthorizationStatus")
    }
  }

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    println("Received an update to Locations")
    if let location = locations.last as? CLLocation {
      println("Last cordinate received is lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
    }
  }

  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    println("Entered a region defined as \(region.description)")
    if (UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
      var notification = UILocalNotification()
      notification.alertAction = "Last place on earth!"
      notification.alertBody = "Note: not actually the last place on earth."
      notification.fireDate = NSDate()
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
  }

  func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    println("Exited a region defined as \(region.description)")
  }

} // End

