//
//  FirstViewController.swift
//  MyLocation
//
//  Created by ChenZexi on 7/3/16.
//  Copyright © 2016 ChenZexi. All rights reserved.
//

import UIKit
import CoreLocation


class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: IB Property
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    // MARK: property
    let locationManager = CLLocationManager()
    
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IB Function
    @IBAction func getLocation(sender: AnyObject) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: CLLocationManager Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! as CLLocation
        print("didUpdateLocaitons \(newLocation)")
    }
    
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .Default,
                                     handler: nil)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }

    
}

