//
//  BarcodeDisplayViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 15/1/17.
//
//  Updated by Jarvie8176 on 01/21/2016
//
//  Copyright (c) 2015年 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes
import CoreLocation
import Alamofire

class BarcodeDisplayViewController: UIViewController, CLLocationManagerDelegate {
    var minorInts = [Int]() // collect minor
    var contents:String = ""
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    // Note: make sure you replace the keys here with your own beacons' Minor Values
    let colors = [
        2760 : UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        44807  : UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        11204: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1),
        61788: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1),
        6118: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1)
    ]

    @IBOutlet weak var label_location: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            self.view.backgroundColor = self.colors[closestBeacon.minor.integerValue]
            if(minorInts.contains(closestBeacon.minor.integerValue)){
                print("not append")
            }else{
                minorInts.append(closestBeacon.minor.integerValue)
                print("append")
                let postsEndpoint: String = "http://192.168.1.36:3000/addapp"
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
                            self.label_location.text = value as? String
                        }//select location
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        }//case
                }//responce
            }//else
        }//if
    }

}
