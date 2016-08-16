//
//  FirstViewController.swift
//  MyLocation
//
//  Created by ChenZexi on 7/3/16.
//  Copyright © 2016 ChenZexi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
	var managedObjectContext: NSManagedObjectContext!


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
    
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IB Function
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
        configureGetButton()

    }
    
    //MARK: - CLLocationManager Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
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

            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** we are done!")
                stopLocationManager()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
				configureGetButton()
				updateLabels()
            }

			//for Geocode
			if !performingReverseGeocoding {
				print("*** Going to Geocode")

				performingReverseGeocoding = true
				geocoder.reverseGeocodeLocation(location!, completionHandler: {placeMarks, error in
					print("*** Found placeMarks: \(placeMarks), error: \(error)")

					self.lastLocationError = error //within the closure, the 'self' key word is a must
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
					self.configureGetButton()

				})
			} else if distance < 1.0 {
				let timeInterval = newLocation.timestamp.timeIntervalSinceDate((location?.timestamp)!)
				if timeInterval > 10 {
					print("*** Force done!!")
					stopLocationManager()
					updateLabels()
					configureGetButton()
				}
			}
        }
    }
	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == "TagLocation" {
			didTimeOut()
			let navigationController = segue.destinationViewController as! UINavigationController
			let controller = navigationController.topViewController as! LocationDetailViewController
			controller.coordinate = location!.coordinate
			controller.placemark = placeMark
			controller.managedObjectContext = managedObjectContext
		}

	}

    //MARK: - Private Method
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
			//拿到了地理位置，messageLabel不再需要展示信息
			messageLabel.text = ""

			if performingReverseGeocoding {
    			tagButton.hidden = true
			} else {
				tagButton.hidden = false
			}

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
            timer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
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
    
    func configureGetButton() {
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
            configureGetButton()
		} else if updatingLocation {
			stopLocationManager()
			updateLabels()
			configureGetButton()
		}
    }

    
}

