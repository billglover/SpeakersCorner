//
//  SCNoteTests.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 18/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import XCTest
@testable import SpeakersCorner

class SCNoteTests: XCTestCase {
    
    func testEquatable() {
        
        let note1 = SCNote(title: "Note A", latitude: 0.001, longitude: 1.001)
        let note1a = SCNote(title: "Note A", latitude: 0.001, longitude: 1.001)
        let note2 = SCNote(title: "Note B", latitude: 0.002, longitude: 2.002, urlAudio: "http://billglover.me/")
        
        let note1Optional: SCNote? = SCNote(title: "Note A", latitude: 0.001, longitude: 1.001)
        let note1aOptional: SCNote? = SCNote(title: "Note A", latitude: 0.001, longitude: 1.001)
        let note2Optional: SCNote? = SCNote(title: "Note B", latitude: 0.002, longitude: 2.002, urlAudio: "http://billglover.me/")

        XCTAssertTrue(note1 != note2)
        XCTAssertTrue(note1 == note1a)
        
        XCTAssertTrue(note1Optional != note2Optional)
        XCTAssertTrue(note1Optional == note1aOptional)

        XCTAssertTrue(note2 == note2Optional)
    }
   
}
