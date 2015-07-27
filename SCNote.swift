//
//  SCNote.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 18/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import Foundation
import CoreLocation

struct SCNote {
    var title: String
    var location: CLLocation
    var urlAudio: NSURL? = nil
    var creationDate: NSDate? = nil
    var modificationDate: NSDate? = nil
    var recordName: String? = nil
    
    
    init(title: String, location: CLLocation, urlAudio: NSURL?) {
        self.title = title
        self.location = location
        self.urlAudio = urlAudio
        self.creationDate = NSDate()
        self.modificationDate = NSDate()
    }
    
    init(title: String, location: CLLocation) {
        self.title = title
        self.location = location
        self.urlAudio = nil
        self.creationDate = NSDate()
        self.modificationDate = NSDate()
    }

}

extension SCNote: Equatable {}

func ==(lhs: SCNote, rhs: SCNote) -> Bool {
    let areEqual = lhs.title == rhs.title &&
                   lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
                   lhs.location.coordinate.longitude == rhs.location.coordinate.longitude &&
                   lhs.location.altitude == rhs.location.altitude &&
                   lhs.urlAudio == rhs.urlAudio
    
    return areEqual
}