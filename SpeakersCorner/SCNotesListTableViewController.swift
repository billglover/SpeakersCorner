//
//  SCNotesListTableViewController.swift
//  SpeakersCorner
//
//  Created by Bill Glover on 19/07/2015.
//  Copyright © 2015 Bill Glover. All rights reserved.
//

import UIKit
import CloudKit

class SCNotesListTableViewController: UITableViewController {
    
    struct Constants {
        static let SCNoteCellReuseIdentifier = "SCNoteCellReuseIdentifier"
        static let recordType = "SCNote"
    }
    
    let db = CKContainer.defaultContainer().publicCloudDatabase
    var items = [SCNote]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.loadNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SCNoteCellReuseIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let item = self.items[indexPath.row]
        let location = item.location
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CloudKit
    
    func loadNotes() {
        let radiusInMeters = 425.0
        let location = CLLocation(latitude: 51.551601, longitude: -0.1981028)
        //let location = CLLocation(latitude: 51.54546434, longitude: -0.19142389)
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < %f", location, radiusInMeters)
        let query = CKQuery(recordType: Constants.recordType, predicate: locationPredicate)
        query.sortDescriptors = [(CKLocationSortDescriptor(key: "location", relativeLocation: location))]
        
        self.db.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let fetchedItems = results as [CKRecord]! {
                        
                        self.items.removeAll()
                        
                        for fetchedItem in fetchedItems {
                            if let note = SCNote(fromRecord: fetchedItem) { self.items.append(note) }
                        }

                        self.tableView.reloadData()
                        print(self.items.count)
                    }
                }
            }
            
        }
        
    }
    
    func addNote() {
        let record = CKRecord(recordType: Constants.recordType)
        record.setObject("Sample", forKey: "title")
        record.setObject(CLLocation(latitude: 0.01, longitude: 0.02), forKey: "location")
        
        self.db.saveRecord(record) { (record, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
