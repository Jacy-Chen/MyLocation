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
    @IBOutlet weak var getButton: UIButton! //must have value
    
    
    // MARK: property
    let locationManager = CLLocationManager()
    var location:CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    let geocoder = CLGeocoder() //init when declear
    var placeMark: CLPlacemark?
    var performingReverseGeocoding = false //the flag to make the app don't send request very often
    var lastGeocodingError:NSError? //maybe have value
    var timer: NSTimer?
    
    
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetBUtton()
        
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
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placeMark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetBUtton()
        
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
        configureGetBUtton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! as CLLocation
        print("didUpdateLocaitons \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || locationManager.desiredAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** we are done!")
                stopLocationManager()
                configureGetBUtton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            //for Geocode
            if !performingReverseGeocoding {
                print("*** Going to Geocode")
                
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(location!, completionHandler: {placeMarks, error in
                    print("*** Found placeMarks: \(placeMarks), error: \(error)")
                    
                    self.lastLocationError = error //within the closure, the 'self' key word is a must
                    
                    //update mark
//                    if error == nil && !(placeMarks?.isEmpty)! {
//                        self.placeMark = (placeMarks?.last)! as CLPlacemark
//                    } else  {
//                        self.placeMark = nil
//                    }
                    
                    if error == nil, let p = placeMarks where !p.isEmpty
                    {
                        self.placeMark = p.last!
                    }
                    else
                    {
                        self.placeMark = nil
                    }
                    
                    //udpate labals & flag
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    
                })
            } else if distance < 1.0 {
                let timeInterval = newLocation.timestamp.timeIntervalSinceDate((location?.timestamp)!)
                if timeInterval > 10 {
                    print("*** Force done!!")
                    stopLocationManager()
                    updateLabels()
                    configureGetBUtton()
                }
            }
        }
        
        
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
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String { // 1
        var line1 = ""
        // 2
        if let s = placemark.subThoroughfare { line1 += s + " "
        }
        // 3
        if let s = placemark.thoroughfare { line1 += s
        }
        // 4
        var line2 = ""
        if let s = placemark.locality { line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
            
        }
        if let s = placemark.postalCode {
            line2 += s }
        // 5
        return line1 + "\n" + line2
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
            
            
            if let placeMark = placeMark {
                addressLabel.text = stringFromPlacemark(placeMark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address"
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error! Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
            
            
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
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
//            timer = NSTimer.scheduledTimerWithTimeInterval(6000, target: self, selector: Selector(didTimeOut()), userInfo: nil, repeats: false)
            
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func configureGetBUtton() {
        if updatingLocation {
            getButton.setTitle("stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func didTimeOut() -> Void {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocaionErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetBUtton()
        }
    }

    
}

