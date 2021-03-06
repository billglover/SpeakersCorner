//
//  SCNotesListTableViewController.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 19/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation
import MapKit

class SCNotesListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    struct Constants {
        static let SCNoteCellReuseIdentifier = "SCNoteCellReuseIdentifier"
        static let recordType = "SCNote"
        static let addNoteSegueIdentifier = "addNoteSegueIdentifier"
    }
    
    let db = CKContainer.defaultContainer().publicCloudDatabase
    var items = [SCNote]()

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Check why this isn't picked up from InterfaceBuilder
        self.tableView.backgroundColor = UIColor(red: 18.0/255, green: 164.0/255, blue: 253.0/255, alpha: 1.0)
        
        // Start fetching location updates
        locationManager.delegate = self
        startTrackingLocation()
        
        // Load a list of notes near the current location
        self.loadNotes()
        
        // Check if the user has an authenticated iCloud Account
        CKContainer.defaultContainer().accountStatusWithCompletionHandler(handleAccountStatusCheck)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleCKAccountChangedNotification"), name: CKAccountChangedNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingLocation()
    }

    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectZero)
        return footerView
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SCNoteCellReuseIdentifier, forIndexPath: indexPath)

        let item = self.items[indexPath.row]
        if let location = currentLocation {
            let distanceFromCurrentLocation = location.distanceFromLocation(item.location)
            let numberFormatter = NSNumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let formatter = NSLengthFormatter()
            formatter.numberFormatter = numberFormatter
            cell.detailTextLabel?.text = "\(formatter.stringFromMeters(distanceFromCurrentLocation))"
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        if item.urlAudio != nil {
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    @IBAction func refreshTableView(sender: AnyObject) {
        loadNotes()
    }
    
    func sortByLocation() {
        if let location = currentLocation {
            items.sortInPlace({return $0.location.distanceFromLocation(location) < $1.location.distanceFromLocation(location)})
        }
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.addNoteSegueIdentifier) {
            // TODO: It might make sense to handle location differently here:
            //  - pass in current location
            //  - stop updating the users location
        }
    }
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {

        if let sourceViewController = segue.sourceViewController as? SCNoteAddViewController {

            // if we don't have a title and a location, we don't add the note
            // TODO: we should check this in SCNoteAddViewController to prevent the user
            //       arriving in this situation as this is a silent failure
            guard let title = sourceViewController.thisLocation?.title else { return }
            guard let location = sourceViewController.thisLocation?.location else { return }
            
            // this code could be moved into SCNoteCloudKit
            let record = CKRecord(recordType: Constants.recordType)
            record.setObject(title, forKey: "title")
            record.setObject(location, forKey: "location")
            
            if let url = sourceViewController.thisLocation?.urlAudio {
                let asset = CKAsset(fileURL: url)
                record["urlAudio"] = asset
            }
            
            // save the record to the cloud
            self.db.saveRecord(record) { (record, error) -> Void in
                if error != nil {
                    
                    // for some errors we will want to notify the user
                    // for others we'll want to cache the record and try again
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - CloudKit
    
    func loadNotes() {
        let radiusInMeters = 1000000000.000
        let location = CLLocation(latitude: 51.551601, longitude: -0.1981028)
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < %f", location, radiusInMeters)
        let query = CKQuery(recordType: Constants.recordType, predicate: locationPredicate)
        query.sortDescriptors = [(CKLocationSortDescriptor(key: "location", relativeLocation: location))]
        
        self.db.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let fetchedItems = results as [CKRecord]! {
                        print(fetchedItems.count)
                        
                        self.items.removeAll()
                        
                        for fetchedItem in fetchedItems {
                            if let note = SCNote(fromRecord: fetchedItem) { self.items.append(note) }
                        }

                        self.sortByLocation()
                        self.tableView.reloadData()
                    }
                }
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    func handleAccountStatusCheck(status: CKAccountStatus, error: NSError?) {

        if (error == nil) {
          
            switch status {
                
            // user is logged in to iCloud
            case .Available:
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                })

            // user is unable to use iCloud
            case .Restricted:
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "iCloud Restricted",
                        message: "It looks like access to iCloud has been restricted on this device. Without an iCloud account you'll be unable to post new notes, but you will be able to view all public notes.",
                        preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                    self.navigationItem.rightBarButtonItem?.enabled = false
                })
            
            // user hasn't yet signed in to iCloud
            case .NoAccount:
                dispatch_async(dispatch_get_main_queue(), {

                    let alertController = UIAlertController(title: "iCloud Desired",
                        message: "It looks like you haven't signed in to iCloud on this device. You don't need an iCloud account to view all our public notes, but if you'd like to leave a note of your own, you'll need to head on over to Settings and sign in to iCloud.",
                        preferredStyle: .Alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (alertAction) in
                        
                        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.sharedApplication().openURL(appSettings)
                        }
                    }
                    alertController.addAction(settingsAction)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.navigationItem.rightBarButtonItem?.enabled = false
                })
                
            // we are unable to determine whether or not the user has an iCloud account
            case .CouldNotDetermine:
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "iCloud Desired",
                        message: "For some reason we were unable to determine hte status of your iCloud account on this device. You don't need an iCloud account to view all our public notes, but if you'd like to leave a note of your own, we'll need to validate your iCloud account. We'll try this next time to see if we have better luck.",
                        preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.navigationItem.rightBarButtonItem?.enabled = false
                })
            }
            
        } else {
            print(error?.localizedDescription)
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationItem.rightBarButtonItem?.enabled = false
            })
        }

    }
    
    // if the iCloud state changes, re-check the users authentication
    func handleCKAccountChangedNotification() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler(handleAccountStatusCheck)
    }
    
    
    
    // MARK: - Location
    func startTrackingLocation() {

        // TODO: If location has been denied, we need to send the user over to settings to grant access
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = CLLocationDistance(10)
            locationManager.startUpdatingLocation()
        }

    }
    
    func stopTrackingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let thisLocation = locations.last {
            print("Time: \(thisLocation.timestamp) Lat: \(thisLocation.coordinate.latitude) Lon: \(thisLocation.coordinate.longitude)")
            currentLocation = thisLocation
            self.sortByLocation()
            self.tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}
