//
//  SCNoteAddViewController.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 25/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import UIKit
import CoreLocation

class SCNoteAddViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationActivitySpinner: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var thisLocation: SCNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        updateLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
        super.viewDidDisappear(animated)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        titleTextField.resignFirstResponder()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        saveNote()
    }

    func saveNote() {
        if let location = currentLocation {
        thisLocation = SCNote(title: titleTextField.text!, location: location)
        }
    }
    
    func updateLocation() {
        latitudeLabel.text = ""
        longitudeLabel.text = ""
        locationActivitySpinner.startAnimating()
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("Time: \(location.timestamp) Lat: \(location.coordinate.latitude) Lon: \(location.coordinate.longitude)")
        }
        
        if let recentLocation = locations.last {
            
            latitudeLabel.text = "\(recentLocation.coordinate.latitude)"
            longitudeLabel.text = "\(recentLocation.coordinate.longitude)"
            locationActivitySpinner.stopAnimating()
            
            currentLocation = recentLocation
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
}
