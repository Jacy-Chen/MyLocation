//
//  LocationDetailViewController.swift
//  MyLocation
//
//  Created by Zexi Chen on 8/11/16.
//  Copyright © 2016 ChenZexi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter:NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateStyle = .MediumStyle
		formatter.timeStyle = .ShortStyle
		return formatter
}()

class LocationDetailViewController: UITableViewController {


	var date = NSDate()
	var managedObjectContext: NSManagedObjectContext!
	let appDelegate = UIApplication.sharedApplication().delegate
		as! AppDelegate
//	let context = appDelegate.managedObjectContext


	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longtitudeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!

	var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	var placemark: CLPlacemark?
	var categoryName = "No Category"
	var descriptionText: String = ""



	//MARK: -  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		descriptionTextView.text = descriptionText
		categoryLabel.text = categoryName

		latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
		longtitudeLabel.text = String(format: "%.8f", coordinate.longitude)

		if let placemark = placemark {
			addressLabel.text = stringFromPlacemark(placemark)
		}
		else {
			addressLabel.text = "No Address Found"
		}

		dateLabel.text = formatDate(date)

		//init 接收两种gestureHandler函数的格式，其中一种可以接受gesture
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailViewController.hideKeyboard(_:)))
		gestureRecognizer.cancelsTouchesInView = false
		tableView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	//MARK: - Inner function
	func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
		let point = gestureRecognizer.locationInView(tableView)
		let indexPath = tableView.indexPathForRowAtPoint(point)

		if indexPath != nil && indexPath?.section == 0
			&& indexPath?.row == 0 {
			return
		}
		//收起键盘
		descriptionTextView.resignFirstResponder()

	}

	func stringFromPlacemark(placeMark: CLPlacemark) -> String {
		var text = ""

		if let s = placemark?.subThoroughfare {
			text += s + ", "
		}
		if let s = placemark?.thoroughfare {
			text += s + ", "
		}
		if let s = placemark?.locality {
			text += s + ", "
		}
		if let s = placemark?.administrativeArea {
			text += s + ", "
		}
		if let s = placemark?.postalCode {
			text += s + ", "
		}
		if let s = placemark?.country {
			text += s
		}
		return text
	}

	func formatDate(date: NSDate) -> String {
		return dateFormatter.stringFromDate(date)
	}

	//MARK: - IBAction 
	@IBAction func done() {
//		dismissViewControllerAnimated(true, completion: nil);
		let hudView = HudView.hudInView((navigationController?.view)!, animated: true)
		hudView.text = "Tagged"

		// 1 获取数据库CoreDate框架
		let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location

		// 2 存储数据
		location.locationDescription = descriptionTextView.text
		location.category = categoryName
		location.latitude = coordinate.latitude
		location.longitude = coordinate.longitude
		location.date = date
		location.placemark = placemark

		// 3
		do {
			try managedObjectContext.save()
		} catch {
			fatalCoreDataError(error)
			return
//			fatalError("Error: \(error)")
		}

		afterDelay(0.6) {
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}

	@IBAction func cancel() {
		dismissViewControllerAnimated(true, completion: nil);
	}

	// MARK: - TableView delegate
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 && indexPath.row == 0 {
			return 88
		}
		else if indexPath.section == 2 && indexPath.row == 2 {
			addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
			addressLabel.sizeToFit()
			addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
			return addressLabel.frame.size.height + 20
		}
		else {
			return 44
		}
	}


	override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if indexPath.section == 0 || indexPath.section == 1 {
			return indexPath
		} else {
			return nil
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 0 && indexPath.row == 0 {
			descriptionTextView.becomeFirstResponder()
		}
	}

	//MARK: - Segue Issues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "PickCategory" {
			let controller = segue.destinationViewController
				as! CategoryPickerTableViewController
			controller.selectedCategoryName = categoryName
		}
	}

	@IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
		let controller = segue.sourceViewController as! CategoryPickerTableViewController
		categoryName = controller.selectedCategoryName
		categoryLabel.text = categoryName
	}

}
