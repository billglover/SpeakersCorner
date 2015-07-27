//
//  SCNoteCloudKit.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 20/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import Foundation
import CloudKit

extension SCNote {
    
    internal struct Constants {
        static let recordType = "SCNote"
    }
    
    init?(fromRecord: CKRecord) {

        // for some reason we have to do this before the guard statements
        // or the compiler throws an error as the convenience initialiser
        // is not called within the guard block
        self.init(title: "", location: CLLocation())
        
        guard let title = fromRecord["title"] as? String else { return nil }
        self.title = title
        
        guard let location = fromRecord["location"] as? CLLocation else { return nil }
        self.location = location
        
        if let asset = fromRecord["urlAudio"] as? CKAsset {
            self.urlAudio = asset.fileURL
        }
        
        self.creationDate = fromRecord.creationDate
        self.modificationDate = fromRecord.modificationDate
        self.recordName = fromRecord.recordID.recordName
        
    }
    
}
