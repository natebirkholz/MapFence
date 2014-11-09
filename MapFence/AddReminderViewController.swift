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

class AddReminderViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

/////////////////////////////////
// MARK: Properties
/////////////////////////////////

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var latLabel: UILabel!
  @IBOutlet weak var longLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var radiusLabel: UILabel!
  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var saveLabel: UILabel!

  var managedObjectContext : NSManagedObjectContext!
  var locationManager : CLLocationManager!
  var selectedAnnotation : MKAnnotation!
  var selectedReminder : Reminder?
  var dateFor : NSDate?
  var mapCamera : MKMapCamera!
  var annotationForView : MKPointAnnotation?
  var radius : Double!
  var overlay : MKOverlay?
  var overlayCircle : MKCircle?

/////////////////////////////////
// MARK: Lifecycle
/////////////////////////////////

  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.managedObjectContext = appDelegate.managedObjectContext
    self.titleTextField.delegate = self
    self.mapView.delegate =  self

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRadius:", name: "SLID_SLIDER", object: nil)

    self.radiusSlider.minimumValue = 10
    self.radiusSlider.maximumValue = 1000
    self.radiusLabel.text = "Radius: " + self.radiusSlider.value.description + "m"
    self.radius = Double(self.radiusSlider.value)

    let regionSet = self.locationManager.monitoredRegions
    let regions = regionSet.allObjects
    let coordinate = self.selectedAnnotation.coordinate
    self.mapView.setCenterCoordinate(coordinate, animated: true)
    self.mapCamera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 2000.0)
    self.mapView.setCamera(self.mapCamera, animated: true)

    if selectedReminder == nil {
      let date = NSDate()
      println(date)
      self.dateFor = date
      println(self.dateFor)
      var dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "dd/MM/yy 'at' HH:mm a"
      let dateString = dateFormatter.stringFromDate(date)

      self.dateLabel.text = dateString
      var latText = self.selectedAnnotation.coordinate.latitude.description as String
      var longText = self.selectedAnnotation.coordinate.longitude.description as String
      self.latLabel.text = "Lat: " + latText
      self.longLabel.text = "Lon: " + longText
      self.titleTextField.placeholder = "Add a Title"
      self.saveButton.hidden = true
      var annotationFor = MKPointAnnotation()
      annotationFor.coordinate = self.selectedAnnotation.coordinate
      annotationFor.title = "Add Reminder"
      self.annotationForView = annotationFor as MKPointAnnotation!
      self.mapView.addAnnotation(annotationFor)

    } else {
      self.titleTextField.text = self.selectedReminder?.reminderName as String!
    }

    self.updateOverlay()
    self.mapView.addOverlay(self.overlayCircle)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

/////////////////////////////////
// MARK: MapView
/////////////////////////////////

  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ANNOTATION")
    annotationView.canShowCallout = true
    return annotationView
  }

  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    let renderer = MKCircleRenderer(overlay: overlay)
    renderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
    renderer.lineWidth = 1.0
    renderer.strokeColor = UIColor.cyanColor()
    renderer.lineDashPattern = [5, 7]
    return renderer
  }

  func updateRadius(notification: NSNotification) {
    println("I hear you")
    println("radius is \(self.radius)")
    println("overlayCiorcle is \(self.overlayCircle?.radius)")
    let userInfo = notification.userInfo!
    self.mapView.removeOverlays(self.mapView.overlays)
    self.updateOverlay()

    self.mapView.addOverlay(self.overlayCircle)
  }

  func updateOverlay() {
    var overlayCircle = MKCircle(centerCoordinate: self.selectedAnnotation.coordinate, radius: self.radius)
    self.overlayCircle = overlayCircle as MKCircle!
  }

/////////////////////////////////
// MARK: User Interaction
/////////////////////////////////
    
  @IBAction func clickedButton(sender: AnyObject) {
    let idString = "Reminder: "
    let radius = self.radius
    let date = self.dateFor as NSDate!
    let identifier = self.titleTextField.text
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

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if countElements(textField.text) > 0 {
      textField.resignFirstResponder()
      return true
    }
    return false
  }

  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    if countElements(textField.text) > 0 {
      self.saveButton.hidden = false
      self.saveLabel.hidden = true
      self.resignFirstResponder()
      return true
    }
    return false
  }

  func textFieldDidEndEditing(textField: UITextField) {
    self.annotationForView?.title = textField.text as String!
    self.mapView.removeAnnotation(self.annotationForView)
    self.mapView.addAnnotation(self.annotationForView)
  }

  @IBAction func radiusSliderSlid(sender: AnyObject) {
    var slider = sender as UISlider
    var value = slider.value
    println(value)
    self.radiusLabel.text = "Radius: " + self.radiusSlider.value.description + "m"
    self.radius = Double(self.radiusSlider.value)
    self.updateOverlay()
    NSNotificationCenter.defaultCenter().postNotificationName("SLID_SLIDER", object: self, userInfo: ["radius": self.radiusSlider.value])
  }

} // End
