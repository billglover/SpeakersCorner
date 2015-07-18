//
//  SCNote.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 18/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

struct SCNote {
    var title: String
    var latitude: Double
    var longitude: Double
    var urlAudio: String? = nil
    
    init(title: String, latitude: Double, longitude: Double, urlAudio: String?) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.urlAudio = urlAudio
    }
    
    init(title: String, latitude: Double, longitude: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.urlAudio = nil
    }
}

extension SCNote: Equatable {}

func ==(lhs: SCNote, rhs: SCNote) -> Bool {
    let areEqual = lhs.title == rhs.title &&
                   lhs.latitude == rhs.latitude &&
                   lhs.longitude == rhs.longitude &&
                   lhs.urlAudio == rhs.urlAudio
    
    return areEqual
}