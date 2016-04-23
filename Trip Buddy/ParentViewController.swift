//Trip Buddy
//ParentViewController.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class ParentViewController: UIViewController {
	//UI elements that are in every view controller
	@IBOutlet weak var country1Button: UIButton!
	@IBOutlet weak var country1ImageView: UIImageView!
	@IBOutlet weak var country1Label: UILabel!
	@IBOutlet weak var country2Button: UIButton!
	@IBOutlet weak var country2ImageView: UIImageView!
	@IBOutlet weak var country2Label: UILabel!

	//Arrays of information where an index in any array pertains to the same country
	let countries: [String] = ["Argentina", "Austria", "Bulgaria", "Canada", "Chile", "China", "France", "Germany",
	                           "India", "Italy", "Japan", "Malaysia", "Mexico", "Singapore", "Spain", "Switzerland",
	                           "United Kingdom", "United States"]

	let currencies: [String] = ["Peso", "Euro", "Lev", "Dollar", "Peso", "Yuan", "Euro", "Euro",
	                            "Rupee", "Euro", "Yen", "Ringgit", "Peso", "Dollar", "Euro", "Franc",
	                            "Pound", "Dollar"]

	let symbols: [String] = ["$", "€", "лев", "$", "$", "¥", "€", "€",
	                         "₹", "€", "¥", "R", "$", "$", "€", "C",
	                         "£", "$"]

	let amounts: [Float] = [9.41, 0.65, 1.75, 1.3336, 704.955, 6.34, 0.65, 0.93,
	                        66.07, 0.94, 122.725, 4.3949, 16.7305, 1.4, 0.92, 0.99,
	                        0.654, 1.5172]

	//CoreData variables for saving program data
	let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var programData: ProgramData? = nil

	//Variables for swiping between tabs
	var startPosition: CGFloat = 0
	let threshold: CGFloat = 30

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		accessProgramData()
		updateCountryElements()
	}

	//Access the program data from CoreData - if it doesn't exist, a default instance is created
	func accessProgramData() {
		var existingData: [ProgramData]

		do {
			existingData = try context.executeFetchRequest(NSFetchRequest(entityName: "ProgramData")) as! [ProgramData]
		} catch _ as NSError {
			existingData = []
		}
		if existingData.count != 1 {
			for i in (existingData.count - 1).stride(through: 0, by: -1) {
				context.deleteObject(existingData[i] as NSManagedObject)
				existingData.removeAtIndex(i)
			}
			existingData = [NSEntityDescription.insertNewObjectForEntityForName("ProgramData", inManagedObjectContext: context) as! ProgramData]
			existingData[0].country1 = countries.count - 1
			existingData[0].country2 = countries.count - 2
			//set all program data default values here as they are created
			saveProgramData()
		}
		programData = existingData[0]
	}

	//Saves the program data to CoreData
	func saveProgramData() {
		do {
			try context.save()
		} catch _ as NSError {}
	}

	//Updates the country UI elements based upon the current program data
	func updateCountryElements() {
		country1Button.setTitle(countries[programData!.country1.integerValue], forState: UIControlState.Normal)
		country1ImageView.image = UIImage(named: countries[programData!.country1.integerValue] + ".png")
		country1Label.text = "\(currencies[programData!.country1.integerValue]) " +
			"(\(symbols[programData!.country1.integerValue])) \(amounts[programData!.country1.integerValue])"
		country2Button.setTitle(countries[programData!.country2.integerValue], forState: UIControlState.Normal)
		country2ImageView.image = UIImage(named: countries[programData!.country2.integerValue] + ".png")
		country2Label.text = "\(currencies[programData!.country2.integerValue]) " +
			"(\(symbols[programData!.country2.integerValue])) \(amounts[programData!.country2.integerValue])"
	}

	//Triggers a menu to pop up for changing country 1
	@IBAction func country1ButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: countries.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countries[i], style: UIAlertActionStyle.Default, handler: country1AlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes country 1 based upon the selected choice
	func country1AlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: countries.count, by: 1) {
			if countries[i] == action.title {
				programData!.country1 = i
				saveProgramData()
				updateCountryElements()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing country 2
	@IBAction func country2ButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: countries.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countries[i], style: UIAlertActionStyle.Default, handler: country2AlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes country 2 based upon the selected choice
	func country2AlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: countries.count, by: 1) {
			if countries[i] == action.title {
				programData!.country2 = i
				saveProgramData()
				updateCountryElements()
				break
			}
		}
	}

	//Tracks movement from the left edge of the screen to determine a tab change
	@IBAction func leftEdgeSwiped(sender: AnyObject) {
		let gestureRecognizer = sender as! UIScreenEdgePanGestureRecognizer

		if gestureRecognizer.state == UIGestureRecognizerState.Began {
			startPosition = gestureRecognizer.locationInView(view).x
		} else if gestureRecognizer.state == UIGestureRecognizerState.Ended && gestureRecognizer.locationInView(view).x - startPosition >= threshold {
			tabBarController!.selectedIndex -= 1
		}
	}

	//Tracks movement from the right edge of the screen to determine a tab change
	@IBAction func rightEdgeSwiped(sender: AnyObject) {
		let gestureRecognizer = sender as! UIScreenEdgePanGestureRecognizer

		if gestureRecognizer.state == UIGestureRecognizerState.Began {
			startPosition = gestureRecognizer.locationInView(view).x
		} else if gestureRecognizer.state == UIGestureRecognizerState.Ended && gestureRecognizer.locationInView(view).x - startPosition <= -threshold {
			tabBarController!.selectedIndex += 1
		}
	}
}