//
//  SCNoteCloudKitTests.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 20/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import XCTest
import CloudKit
@testable import SpeakersCorner


class SCNoteCloudKitTests: XCTestCase {

    func testExample() {
        
        let record = CKRecord(recordType: SCNote.Constants.recordType, recordID: CKRecordID(recordName: "SampleRecordName"))
        let location = CLLocation(latitude: 0.001, longitude: 1.001)
        
        record["title"] = "Sample Title"
        record["location"] = location
        
        let note = SCNote(fromRecord: record)
        XCTAssertEqual((note?.title)!, record["title"] as! String)
        XCTAssertEqual((note?.location)!, location)
        XCTAssertEqual((note?.recordName)!, record.recordID.recordName)
    }

}
