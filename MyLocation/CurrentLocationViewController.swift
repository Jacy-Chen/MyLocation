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
    var location:CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        
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
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
        
    }
    
    //MARK: CLLocationManager Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! as CLLocation
        print("didUpdateLocaitons \(newLocation)")
        
        lastLocationError = nil
        location = newLocation
        updateLabels()
    }
    
    //MARK: Private Method
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
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            
            //handle the error here:
            let statusMessage: String
            if let error = lastLocationError {// lastLocationError is not nil
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                }
                else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }

    
}

