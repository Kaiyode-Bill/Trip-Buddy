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

	override func viewDidLoad() {
		super.viewDidLoad()

		//Initialize each of the view controllers and add them into the scroll view
		for i in 0.stride(to: viewControllers.count, by: 1) {
			viewControllers[i].view.frame.origin.x = view.frame.size.width * CGFloat(i)
			scrollView.addSubview(viewControllers[i].view)
			//view controller intialization stuff goes here
		}
		scrollView.contentSize = CGSizeMake(view.frame.size.width * CGFloat(viewControllers.count), scrollView.bounds.height)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		accessProgramData()
		updateUIElements()
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

	//Updates the UI elements based upon the current program data
	func updateUIElements() {
		let country1 = countries[programData!.country1.integerValue]
		let currency1 = currencies[programData!.country1.integerValue]
		let symbol1 = symbols[programData!.country1.integerValue]
		let country2 = countries[programData!.country2.integerValue]
		let currency2 = currencies[programData!.country2.integerValue]
		let symbol2 = symbols[programData!.country2.integerValue]

		country1ImageView.image = UIImage(named: country1 + ".png")
		country1Button.setTitle("Country of Origin: \(country1) - \(currency1) (\(symbol1))", forState: UIControlState.Normal)
		country2ImageView.image = UIImage(named: country2 + ".png")
		country2Button.setTitle("Country of Travel: \(country2) - \(currency2) (\(symbol2))", forState: UIControlState.Normal)
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
				updateUIElements()
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
				updateUIElements()
				break
			}
		}
	}

	//Changes the scroll view depending upon what bottom button was pressed
	@IBAction func bottomButtonPressed(sender: AnyObject) {
		scrollView.contentOffset = CGPointMake(view.frame.size.width * CGFloat(sender.tag), 0)
	}
}