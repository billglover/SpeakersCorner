//
//  SCNoteAddViewController.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 25/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class SCNoteAddViewController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationActivitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioPositionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var thisLocation: SCNote?
    
    var recordingSession: AVAudioSession!
    var noteRecorder: AVAudioRecorder!
    var notePlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        updateLocation()
        
        playButton.hidden = true
        playButton.alpha = 0.0
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {
                [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.recordButton.enabled = true
                        self.playButton.enabled = true
                        self.audioPositionLabel.text = "00:00"
                    } else {
                        self.recordButton.enabled = false
                        self.playButton.enabled = false
                        self.audioPositionLabel.text = "unavailable"
                        print("Recording unavailable. Perhaps the App doesn't have access to the microphone.")
                    }
                }
            }
            
        } catch {
            print("Unable to establish recording session")
        }
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
            thisLocation = SCNote(title: titleTextField.text!, location: location, urlAudio: SCNoteAddViewController.getNoteURL())
        }
    }
    
    
    
    // MARK: - Location
    
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
    
    
    
    // MARK: - Audio Recording
    class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getNoteURL() -> NSURL {
        let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent("note.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        return audioURL
    }
    
    func startRecording() {
        audioPositionLabel.textColor = UIColor.redColor()
        recordButton.setTitle("Stop", forState: .Normal)
        
        let audioURL = SCNoteAddViewController.getNoteURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            noteRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            noteRecorder.delegate = self
            noteRecorder.record()
            
            if !playButton.hidden {
                UIView.animateWithDuration(0.35) { [unowned self] in
                    self.playButton.hidden = true
                    self.playButton.alpha = 0
                }
            }
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool) {
        audioPositionLabel.textColor = UIColor.blackColor()
        
        noteRecorder.stop()
        noteRecorder = nil
        
        if success {
            recordButton.setTitle("Re-Record", forState: .Normal)
            
            // show the play button
            if playButton.hidden {
                UIView.animateWithDuration(0.35) { [unowned self] in
                    self.playButton.hidden = false
                    self.playButton.alpha = 1
                }
            }
            
        } else {
            recordButton.setTitle("Record", forState: .Normal)
            
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your note; please try again.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction func recordTapped(sender: UIButton) {
        if noteRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func playTapped(sender: UIButton) {
        let audioURL = SCNoteAddViewController.getNoteURL()
            
        do {
            notePlayer = try AVAudioPlayer(contentsOfURL: audioURL)
            notePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your note; please try re-recording.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
}
