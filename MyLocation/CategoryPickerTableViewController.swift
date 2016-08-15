//
//  CategoryPickerTableViewController.swift
//  MyLocation
//
//  Created by Zexi Chen on 8/12/16.
//  Copyright © 2016 ChenZexi. All rights reserved.
//

import UIKit

class CategoryPickerTableViewController: UITableViewController {

	var selectedCategoryName = ""

	let categories = [
		"No Category", "Apple Store", "Bar", "Bookstore", "Club",
		"Grocery Store", "Historic Building", "House", "Office",
		"Icecream Vendor", "Landmark",
		"Park"
	]

	var selectedIndexPath = NSIndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()

		for i in 0..<categories.count {
			if categories[i] == selectedCategoryName {
    			selectedIndexPath = NSIndexPath(forRow: i, inSection:  0 )
				break
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

		let categoryName = categories[indexPath.row]
		cell.textLabel?.text = categoryName

		if categoryName == selectedCategoryName {
			cell.accessoryType = .Checkmark
		} else {
			cell.accessoryType = .None
		}

		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//change mark type
		if indexPath.row != selectedIndexPath.row {
			if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
				newCell.accessoryType = .Checkmark
			}

			if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
				oldCell.accessoryType = .None
			}

			selectedIndexPath = indexPath
		}
	}


    // MARK: - Navigation Segue Issue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "PickedCategory" {
			let cell = sender as! UITableViewCell
			if let indexPath = tableView.indexPathForCell(cell)	{
				selectedCategoryName = categories[indexPath.row]
			}
		}

    }


}
