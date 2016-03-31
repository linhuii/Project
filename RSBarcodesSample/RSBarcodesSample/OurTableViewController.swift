//
//  OurTableViewController.swift
//  RSBarcodesSample
//
//  Created by Pantira Naruphanthawart on 3/30/2559 BE.
//  Copyright © 2559 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes
import CoreLocation
import Alamofire

class OurTableViewController: UITableViewController, CLLocationManagerDelegate {
    var minorInts = [Int]() // collect minor
    var contents:String = "" // string barcode
    let pargraphone = "test one"
    let pargraphtwo = "test two"
    let pargraphthree = "test three"
    var poem: [String] {return [pargraphone,pargraphtwo,pargraphthree]}
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    let colors = [
        2760 : UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        44807  : UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        11204: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1),
        61788: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1),
        6118: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.title = contents
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.whiteColor()
        gen.strokeColor = UIColor.blackColor()
        print ("generating image with barcode: " + contents)
        
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeaconsInRegion(region)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return poem.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OurCell", forIndexPath: indexPath) as! OurTableViewCell
        cell.ourCellLable.text=poem[indexPath.section]
        // Configure the cell...

        return cell
    }
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
           // self.view.backgroundColor = self.colors[closestBeacon.minor.integerValue]
            if(minorInts.contains(closestBeacon.minor.integerValue)){
                print("not append")
            }else{
                minorInts.append(closestBeacon.minor.integerValue)
                print("append")
                let postsEndpoint: String = "http://192.168.106.118:3000/addapp"
                let parameters = ["minor": closestBeacon.minor.stringValue,"major":closestBeacon.major.stringValue]
                Alamofire.request(.POST, postsEndpoint, parameters: parameters).responseJSON
                    { response in switch response.result {
                    case .Success(let JSON):
                        print("Success with JSON: \(JSON)")
                        var dictionaries=[[String: AnyObject]]()
                        for location in JSON as! [[String: AnyObject]] {
                            print(location)
                            dictionaries.append(location)
                        }//for loop
                        if let value = dictionaries[0]["location"] {
                            print(value)
                            //self.label_location.text = value as? String
                        }//select location
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        }//case
                }//responce
            }//else
        }//if
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
        // Return false if you do not want the item to be re-orderable.
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

}
