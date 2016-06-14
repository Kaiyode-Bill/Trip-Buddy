//Trip Buddy
//TripBuddyViewController.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class TripBuddyViewController: UIViewController {
	//All of the UI elements
	@IBOutlet weak var originCountryImageView: UIImageView!
	@IBOutlet weak var originCountryButton: UIButton!
	@IBOutlet weak var travelCountryImageView: UIImageView!
	@IBOutlet weak var travelCountryButton: UIButton!
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

	let currencies: [String] = ["Pesos", "Euros", "Leva", "Dollars", "Pesos", "Yuan", "Euros", "Euros",
	                            "Rupees", "Euros", "Yen", "Ringgits", "Pesos", "Dollars", "Euros", "Francs",
	                            "Pounds", "Dollars"]

	let symbols: [String] = ["$", "€", "лев", "$", "$", "¥", "€", "€",
	                         "₹", "€", "¥", "R", "$", "$", "€", "C",
	                         "£", "$"]

	let weights: [Double] = [9.41, 0.65, 1.75, 1.3336, 704.955, 6.34, 0.65, 0.93,
	                        66.07, 0.94, 122.725, 4.3949, 16.7305, 1.4, 0.92, 0.99,
	                        0.654, 1.5172]

	//Miscellaneous information
	let miscUnits: [[String]] = [["Miles (or MPH)", "Kilometers (or km/h)"], ["° Farenheit", "° Celsius"]]
	let miscMeasurements: [String] = ["distance", "temperature"]

	//CoreData variables for saving program data
	let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var programData: ProgramData? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		//Initialize each of the view controllers and add them into the scroll view
		for i in 0.stride(to: viewControllers.count, by: 1) {
			viewControllers[i].view.frame.size.height = scrollView.bounds.height
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
			existingData[0].originCountry = names.count - 1
			existingData[0].travelCountry = names.count - 2
			existingData[0].showHelpAtStartup = 1
			existingData[0].exchangeAmount = 0
			existingData[0].exchangePercentage = 0
			existingData[0].exchangeOutcome = 0
			existingData[0].gasUnit = 1
			existingData[0].gasAmount = 0
			existingData[0].gasRate = 0
			existingData[0].gasOutcome = 0
			existingData[0].gasConvertedUnit = 0
			existingData[0].mealsAmount = 0
			existingData[0].mealsPercentage = 0
			existingData[0].mealsPeople = 1
			existingData[0].mealsOutcome = 0
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

		//Relevant country information
		let originName = names[programData!.originCountry.integerValue]
		let originCurrency = currencies[programData!.originCountry.integerValue]
		let originSymbol = symbols[programData!.originCountry.integerValue]
		let travelName = names[programData!.travelCountry.integerValue]
		let travelCurrency = currencies[programData!.travelCountry.integerValue]
		let travelSymbol = symbols[programData!.travelCountry.integerValue]
		//Relevant exchange information
		let exchangeViewController = viewControllers[0] as! ExchangeViewController
		//Relevant gas information
		let gasViewController = viewControllers[1] as! GasViewController
		//
		//Relevant meal information
		let mealsViewController = viewControllers[2] as! MealsViewController
		//
		//Relevant miscellaneous information
		let miscViewController = viewControllers[3] as! MiscViewController
		let miscUnit = miscUnits[programData!.miscMeasurement.integerValue][programData!.miscUnit.integerValue]
		let miscConvertedUnit = miscUnits[programData!.miscMeasurement.integerValue][1 - programData!.miscUnit.integerValue]
		let miscMeasurement = miscMeasurements[programData!.miscMeasurement.integerValue]

		//Update TripBuddyViewController's elements
		originCountryImageView.image = UIImage(named: originName + ".png")
		originCountryButton.setTitle("Origin Country: \(originName)", forState: UIControlState.Normal)
		travelCountryImageView.image = UIImage(named: travelName + ".png")
		travelCountryButton.setTitle("Travel Country: \(travelName)", forState: UIControlState.Normal)
		//Update ExchangeViewController's elements
		exchangeViewController.conversionLabel.text = "Converting \(originCurrency) to \(travelCurrency):"
		exchangeViewController.rateLabel.text = "\(originSymbol) 1.00 = \(travelSymbol) \(String(format: "%.2f", exchangeRate()))"
		exchangeViewController.amountLabel1.text = "If I convert (\(originSymbol))"
		exchangeViewController.amountTextField.text = String(format: "%.2f", programData!.exchangeAmount.doubleValue)
		exchangeViewController.amountLabel2.text = originCurrency
		exchangeViewController.percentageTextField.text = String(format: "%.2f", programData!.exchangePercentage.doubleValue)
		exchangeViewController.feeLabel.text = "(which equals \(originSymbol) \(String(format: "%.2f", exchangeFee())) \(originCurrency))"
		exchangeViewController.resultLabel.text = "then I should get \(travelSymbol) \(String(format: "%.2f", exchangeResult())) \(travelCurrency)"
		exchangeViewController.outcomeLabel1.text = "If I got (\(travelSymbol))"
		exchangeViewController.outcomeTextField.text = String(format: "%.2f", programData!.exchangeOutcome.doubleValue)
		exchangeViewController.outcomeLabel2.text = travelCurrency
		if exchangeDifference() == 0 {
			exchangeViewController.differenceLabel.text = "then it was a fair conversion"
		} else if exchangeDifference() > 0 {
			exchangeViewController.differenceLabel.text = "then you got \(travelSymbol) \(exchangeDifference()) \(travelCurrency) extra"
		} else {
			exchangeViewController.differenceLabel.text = "then you are short \(travelSymbol) \(-exchangeDifference()) \(travelCurrency)"
		}
		//Update GasViewController's elements
		//
		//Update MealsViewController's elements
		//
		//Update MiscViewController's elements
		miscViewController.measurementControl.selectedSegmentIndex = programData!.miscMeasurement.integerValue
		miscViewController.amountTextField.text = String(format: "%.3f", programData!.miscAmount.doubleValue)
		miscViewController.unitLabel.text = miscUnit
		miscViewController.equivalentLabel.text = "is equal to \(String(format: "%.3f", miscConvertedAmount())) \(miscConvertedUnit)"
		miscViewController.toggleButton.setTitle("Switch the \(miscMeasurement) units", forState: UIControlState.Normal)
	}

	//Returns the exchange rate between the origin country and the travel country
	func exchangeRate() -> Double {
		return weights[programData!.travelCountry.integerValue] / weights[programData!.originCountry.integerValue]
	}

	//Returns the exchange fee, which is the exchange amount times the exchange percentage
	func exchangeFee() -> Double {
		return programData!.exchangeAmount.doubleValue * (programData!.exchangePercentage.doubleValue / 100)
	}

	//Returns the exchange result, which is the exchange fee divided by the exchange rate
	func exchangeResult() -> Double {
		return exchangeFee() / exchangeRate()
	}

	//Returns the exchange difference, which is the exchange outcome minues the exchange result
	func exchangeDifference() -> Double {
		return programData!.exchangeOutcome.doubleValue - exchangeResult()
	}

	//Returns the converted amount from the MiscViewController
	func miscConvertedAmount() -> Double {
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

	//Triggers a menu to pop up for changing the origin country
	@IBAction func originCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: names.count, by: 1) {
			alertController.addAction(UIAlertAction(title: names[i], style: UIAlertActionStyle.Default, handler: originCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes the origin country based upon the selected choice
	func originCountryAlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: names.count, by: 1) {
			if names[i] == action.title {
				programData!.originCountry = i
				saveProgramData()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing the travel country
	@IBAction func travelCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: names.count, by: 1) {
			alertController.addAction(UIAlertAction(title: names[i], style: UIAlertActionStyle.Default, handler: travelCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes the travel country based upon the selected choice
	func travelCountryAlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: names.count, by: 1) {
			if names[i] == action.title {
				programData!.travelCountry = i
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