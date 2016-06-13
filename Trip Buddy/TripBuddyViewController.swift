//Trip Buddy
//TripBuddyViewController.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class TripBuddyViewController: UIViewController {
	//All of the UI elements
	@IBOutlet weak var country1ImageView: UIImageView!
	@IBOutlet weak var country1Button: UIButton!
	@IBOutlet weak var country2ImageView: UIImageView!
	@IBOutlet weak var country2Button: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!

	//The individual view controllers
	let viewControllers: [ParentViewController] = [ExchangeViewController(nibName: "ExchangeViewController", bundle: nil),
	                                               GasViewController(nibName: "GasViewController", bundle: nil),
	                                               MealsViewController(nibName: "MealsViewController", bundle: nil),
	                                               MiscViewController(nibName: "MiscViewController", bundle: nil)]

	//Arrays of information where an index in any array pertains to the same country
	let names: [String] = ["Argentina", "Austria", "Bulgaria", "Canada", "Chile", "China", "France", "Germany",
	                           "India", "Italy", "Japan", "Malaysia", "Mexico", "Singapore", "Spain", "Switzerland",
	                           "United Kingdom", "United States"]

	let currencies: [String] = ["Peso", "Euro", "Lev", "Dollar", "Peso", "Yuan", "Euro", "Euro",
	                            "Rupee", "Euro", "Yen", "Ringgit", "Peso", "Dollar", "Euro", "Franc",
	                            "Pound", "Dollar"]

	let symbols: [String] = ["$", "€", "лев", "$", "$", "¥", "€", "€",
	                         "₹", "€", "¥", "R", "$", "$", "€", "C",
	                         "£", "$"]

	let weights: [Double] = [9.41, 0.65, 1.75, 1.3336, 704.955, 6.34, 0.65, 0.93,
	                        66.07, 0.94, 122.725, 4.3949, 16.7305, 1.4, 0.92, 0.99,
	                        0.654, 1.5172]

	//Miscellaneous data
	let miscUnits: [[String]] = [["Miles (or MPH)", "Kilometers (or km/h)"], ["° Farenheit", "° Celsius"]]
	let miscLabels: [String] = ["distance", "temperature"]

	//CoreData variables for saving program data
	let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var programData: ProgramData? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		//Initialize each of the view controllers and add them into the scroll view
		for i in 0.stride(to: viewControllers.count, by: 1) {
			viewControllers[i].view.frame.origin.x = view.frame.size.width * CGFloat(i)
			scrollView.addSubview(viewControllers[i].view)
			viewControllers[i].tripBuddyViewController = self
		}
		scrollView.contentSize = CGSizeMake(view.frame.size.width * CGFloat(viewControllers.count), scrollView.bounds.height)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		var existingData: [ProgramData]

		//Access the program data from CoreData
		do {
			existingData = try context.executeFetchRequest(NSFetchRequest(entityName: "ProgramData")) as! [ProgramData]
		} catch _ as NSError {
			existingData = []
		}
		//If valid program data doesn't exist, create a default instance instead
		if existingData.count != 1 {
			for i in (existingData.count - 1).stride(through: 0, by: -1) {
				context.deleteObject(existingData[i] as NSManagedObject)
				existingData.removeAtIndex(i)
			}
			existingData = [NSEntityDescription.insertNewObjectForEntityForName("ProgramData", inManagedObjectContext: context) as! ProgramData]
			existingData[0].country1 = names.count - 1
			existingData[0].country2 = names.count - 2
			//set all program data default values here as they are created
			existingData[0].miscMeasurement = 0
			existingData[0].miscAmount = 0
			existingData[0].miscUnit = 0
		}
		programData = existingData[0]
		saveProgramData()
	}

	//Saves the program data to CoreData and then updates all of the UI elements
	func saveProgramData() {
		do {
			try context.save()
		} catch _ as NSError {}

		let name1 = names[programData!.country1.integerValue]
		//let currency1 = currencies[programData!.country1.integerValue]
		//let symbol1 = symbols[programData!.country1.integerValue]
		//let weight1 = weights[programData!.country1.integerValue]
		let name2 = names[programData!.country2.integerValue]
		//let currency2 = currencies[programData!.country2.integerValue]
		//let symbol2 = symbols[programData!.country2.integerValue]
		//let weight2 = weights[programData!.country2.integerValue]
		let miscViewController = viewControllers[3] as! MiscViewController
		let miscUnit1 = miscUnits[programData!.miscMeasurement.integerValue][programData!.miscUnit.integerValue]
		let miscUnit2 = miscUnits[programData!.miscMeasurement.integerValue][1 - programData!.miscUnit.integerValue]
		let miscLabel = miscLabels[programData!.miscMeasurement.integerValue]

		country1ImageView.image = UIImage(named: name1 + ".png")
		country1Button.setTitle("Origin Country: \(name1)", forState: UIControlState.Normal)
		country2ImageView.image = UIImage(named: name2 + ".png")
		country2Button.setTitle("Travel Country: \(name2)", forState: UIControlState.Normal)
		miscViewController.measurementControl.selectedSegmentIndex = programData!.miscMeasurement.integerValue
		miscViewController.amountTextField.text = String(format: "%.3f", programData!.miscAmount.doubleValue)
		miscViewController.unitLabel.text = miscUnit1
		miscViewController.equivalentLabel.text = "is equal to \(String(format: "%.3f", convertedMiscAmount())) \(miscUnit2)"
		miscViewController.toggleButton.setTitle("Switch the \(miscLabel) units", forState: UIControlState.Normal)
	}

	//Returns the converted amount from the MiscViewController
	func convertedMiscAmount() -> Double {
		if programData!.miscMeasurement == 0 && programData!.miscUnit == 0 {
			return programData!.miscAmount.doubleValue * 25146 / 15625
		} else if programData!.miscMeasurement == 0 && programData!.miscUnit != 0 {
			return programData!.miscAmount.doubleValue * 15625 / 25146
		} else if programData!.miscMeasurement != 0 && programData!.miscUnit == 0 {
			return (programData!.miscAmount.doubleValue - 32) * 5 / 9
		} else {
			return (programData!.miscAmount.doubleValue * 9 / 5) + 32
		}
	}

	//Triggers a menu to pop up for changing country 1
	@IBAction func country1ButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: names.count, by: 1) {
			alertController.addAction(UIAlertAction(title: names[i], style: UIAlertActionStyle.Default, handler: country1AlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes country 1 based upon the selected choice
	func country1AlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: names.count, by: 1) {
			if names[i] == action.title {
				programData!.country1 = i
				saveProgramData()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing country 2
	@IBAction func country2ButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: names.count, by: 1) {
			alertController.addAction(UIAlertAction(title: names[i], style: UIAlertActionStyle.Default, handler: country2AlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes country 2 based upon the selected choice
	func country2AlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: names.count, by: 1) {
			if names[i] == action.title {
				programData!.country2 = i
				saveProgramData()
				break
			}
		}
	}

	//Changes the scroll view depending upon what bottom button was pressed
	@IBAction func bottomButtonPressed(sender: AnyObject) {
		scrollView.contentOffset = CGPointMake(view.frame.size.width * CGFloat(sender.tag), 0)
	}
}