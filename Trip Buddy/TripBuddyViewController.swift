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
	                                               MealViewController(nibName: "MealViewController", bundle: nil),
	                                               MiscViewController(nibName: "MiscViewController", bundle: nil)]

	//Arrays of information where an index in any array pertains to the same country
	let countryNames: [String] = ["Argentina", "Austria", "Bulgaria", "Canada", "Chile", "China", "France", "Germany",
	                              "India", "Italy", "Japan", "Malaysia", "Mexico", "Singapore", "Spain", "Switzerland",
	                              "United Kingdom", "United States"]

	let countryCurrencies: [String] = ["Pesos", "Euros", "Leva", "Dollars", "Pesos", "Yuan", "Euros", "Euros",
	                                   "Rupees", "Euros", "Yen", "Ringgits", "Pesos", "Dollars", "Euros", "Francs",
	                                   "Pounds", "Dollars"]

	let countrySymbols: [String] = ["$", "€", "лев", "$", "$", "¥", "€", "€",
	                                "₹", "€", "¥", "R", "$", "$", "€", "C",
	                                "£", "$"]

	let countryWeights: [Double] = [9.41, 0.65, 1.75, 1.3336, 704.955, 6.34, 0.65, 0.93,
	                                66.07, 0.94, 122.725, 4.3949, 16.7305, 1.4, 0.92, 0.99,
	                                0.654, 1.5172]

	//Gas information
	let gasUnitsPlural: [String] = ["U.S. Gallons", "Imp. Gallons", "Liters"]

	let gasUnitsSingular: [String] = ["US Gal.", "Imp Gal.", "Liter"]

	let gasWeights: [Double] = [1000000000, 832673840, 3785411784]

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
			existingData[0].originCountry = countryNames.count - 1
			existingData[0].travelCountry = countryNames.count - 2
			existingData[0].showHelpAtStartup = 1
			existingData[0].exchangeAmount = 0
			existingData[0].exchangePercentage = 0
			existingData[0].exchangeOutcome = 0
			existingData[0].gasUnit = 1
			existingData[0].gasAmount = 0
			existingData[0].gasRate = 0
			existingData[0].gasOutcome = 0
			existingData[0].gasConvertedUnit = 0
			existingData[0].mealAmount = 0
			existingData[0].mealPercentage = 0
			existingData[0].mealPeople = 1
			existingData[0].mealOutcome = 0
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
		let originName = countryNames[programData!.originCountry.integerValue]
		let originCurrency = countryCurrencies[programData!.originCountry.integerValue]
		let originSymbol = countrySymbols[programData!.originCountry.integerValue]
		let travelName = countryNames[programData!.travelCountry.integerValue]
		let travelCurrency = countryCurrencies[programData!.travelCountry.integerValue]
		let travelSymbol = countrySymbols[programData!.travelCountry.integerValue]
		//Relevant exchange information
		let exchangeViewController = viewControllers[0] as! ExchangeViewController
		//Relevant gas information
		let gasViewController = viewControllers[1] as! GasViewController
		let gasUnitPlural = gasUnitsPlural[programData!.gasUnit.integerValue]
		let gasUnitSingular = gasUnitsSingular[programData!.gasUnit.integerValue]
		let gasConvertedUnitPlural = gasUnitsPlural[programData!.gasConvertedUnit.integerValue]
		let gasConvertedUnitSingular = gasUnitsSingular[programData!.gasConvertedUnit.integerValue]
		//Relevant meal information
		let mealViewController = viewControllers[2] as! MealViewController
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
		exchangeViewController.rateLabel.text = "\(originSymbol) 1.00 = \(travelSymbol) \(String(format: "%.2f", countryExchangeRate()))"
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
			exchangeViewController.differenceLabel.text = "then you got \(travelSymbol) \(String(format: "%.2f", exchangeDifference())) \(travelCurrency) extra"
		} else {
			exchangeViewController.differenceLabel.text = "then you are short \(travelSymbol) \(String(format: "%.2f", -exchangeDifference())) \(travelCurrency)"
		}
		//Update GasViewController's elements
		gasViewController.unitControl.selectedSegmentIndex = programData!.gasUnit.integerValue
		gasViewController.amountTextField.text = String(format: "%.2f", programData!.gasAmount.doubleValue)
		gasViewController.amountLabel2.text = gasUnitPlural
		gasViewController.rateLabel1.text = "at a rate of (\(travelSymbol))"
		gasViewController.rateTextField.text = String(format: "%.2f", programData!.gasRate.doubleValue)
		gasViewController.rateLabel2.text = "\(travelCurrency)/\(gasUnitSingular)"
		gasViewController.resultLabel.text = "then I should pay \(travelSymbol) \(String(format: "%.2f", gasResult())) \(travelCurrency)"
		gasViewController.outcomeLabel1.text = "If I paid (\(travelSymbol))"
		gasViewController.outcomeTextField.text = String(format: "%.2f", programData!.gasOutcome.doubleValue)
		gasViewController.outcomeLabel2.text = travelCurrency
		if gasDifference() == 0 {
			gasViewController.differenceLabel.text = "then it was a fair transaction"
		} else if gasDifference() > 0 {
			gasViewController.differenceLabel.text = "then you got \(travelSymbol) \(String(format: "%.2f", gasDifference())) \(travelCurrency) extra"
		} else {
			gasViewController.differenceLabel.text = "then you are short \(travelSymbol) \(String(format: "%.2f", -gasDifference())) \(travelCurrency)"
		}
		gasViewController.convertedUnitControl.selectedSegmentIndex = programData!.gasConvertedUnit.integerValue
		gasViewController.convertedAmountLabel.text = "As such, I bought \(String(format: "%.2f", gasConvertedAmount())) \(gasConvertedUnitPlural)"
		gasViewController.convertedRateLabel.text = "at a rate of \(originSymbol) \(String(format: "%.2f", gasConvertedRate())) \(originCurrency)/\(gasConvertedUnitSingular)"
		gasViewController.convertedResultLabel.text = "which is worth \(originSymbol) \(String(format: "%.2f", gasConvertedResult())) \(originCurrency)"
		gasViewController.convertedOutcomeLabel.text = "but I paid roughly \(originSymbol) \(String(format: "%.2f", gasConvertedOutcome())) \(originCurrency)"
		gasViewController.convertedDifferenceLabel.text = "with a difference of \(originSymbol) \(String(format: "%.2f", gasConvertedDifference())) \(originCurrency)"
		//Update MealViewController's elements
		mealViewController.amountLabel1.text = "The check is (\(travelSymbol))"
		mealViewController.amountTextField.text = String(format: "%.2f", programData!.mealAmount.doubleValue)
		mealViewController.amountLabel2.text = travelCurrency
		mealViewController.percentageTextField.text = String(format: "%.2f", programData!.mealPercentage.doubleValue)
		mealViewController.tipLabel.text = "(which equals \(travelSymbol) \(String(format: "%.2f", mealTip())) \(travelCurrency))"
		mealViewController.totalLabel.text = "then the total is \(travelSymbol) \(String(format: "%.2f", mealTotal())) \(travelCurrency)"
		mealViewController.peopleTextField.text = String(programData!.mealPeople.integerValue)
		mealViewController.resultLabel.text = "then I should pay \(travelSymbol) \(String(format: "%.2f", mealResult())) \(travelCurrency)"
		mealViewController.outcomeLabel1.text = "If I paid (\(travelSymbol))"
		mealViewController.outcomeTextField.text = String(format: "%.2f", programData!.mealOutcome.doubleValue)
		mealViewController.outcomeLabel2.text = travelCurrency
		if mealDifference() == 0{
			mealViewController.differenceLabel.text = "then it was a fair transaction"
		} else if mealDifference() > 0 {
			mealViewController.differenceLabel.text = "then you got \(travelSymbol) \(String(format: "%.2f", mealDifference())) \(travelCurrency) extra"
		} else {
			mealViewController.differenceLabel.text = "then you are short \(travelSymbol) \(String(format: "%.2f", -mealDifference())) \(travelCurrency)"
		}
		mealViewController.convertedUnitLabel.text = "In converting these values to \(originCurrency):"
		mealViewController.convertedAmountLabel.text = "The check was \(originSymbol) \(String(format: "%.2f", mealConvertedAmount())) \(originCurrency)"
		mealViewController.convertedTipLabel.text = "with a tip of \(originSymbol) \(String(format: "%.2f", mealConvertedTip())) \(originCurrency)"
		mealViewController.convertedTotalLabel.text = "and the total was \(originSymbol) \(String(format: "%.2f", mealConvertedTotal())) \(originCurrency)"
		mealViewController.convertedResultLabel.text = "costing each person \(originSymbol) \(String(format: "%.2f", mealConvertedResult())) \(originCurrency)"
		mealViewController.convertedOutcomeLabel.text = "but I paid roughly \(originSymbol) \(String(format: "%.2f", mealConvertedOutcome())) \(originCurrency)"
		mealViewController.convertedDifferenceLabel.text = "with a difference of \(originSymbol) \(String(format: "%.2f", mealConvertedDifference())) \(originCurrency)"
		//Update MiscViewController's elements
		miscViewController.measurementControl.selectedSegmentIndex = programData!.miscMeasurement.integerValue
		miscViewController.amountTextField.text = String(format: "%.3f", programData!.miscAmount.doubleValue)
		miscViewController.unitLabel.text = miscUnit
		miscViewController.equivalentLabel.text = "is equal to \(String(format: "%.3f", miscConvertedAmount())) \(miscConvertedUnit)"
		miscViewController.toggleButton.setTitle("Switch the \(miscMeasurement) units", forState: UIControlState.Normal)
	}

	//Returns the exchange rate between the origin country and the travel country
	func countryExchangeRate() -> Double {
		return countryWeights[programData!.travelCountry.integerValue] / countryWeights[programData!.originCountry.integerValue]
	}

	//Returns the exchange fee, which is the exchange amount times the exchange percentage
	func exchangeFee() -> Double {
		return programData!.exchangeAmount.doubleValue * (programData!.exchangePercentage.doubleValue / 100)
	}

	//Returns the exchange result, which is the exchange fee times the country exchange rate
	func exchangeResult() -> Double {
		return exchangeFee() * countryExchangeRate()
	}

	//Returns the exchange difference, which is the exchange outcome minues the exchange result
	func exchangeDifference() -> Double {
		return programData!.exchangeOutcome.doubleValue - exchangeResult()
	}

	//Returns the gas result, which is the gas amount times the gas rate
	func gasResult() -> Double {
		return programData!.gasAmount.doubleValue * programData!.gasRate.doubleValue
	}

	//Returns the gas difference, which is the gas outcome minus the gas result
	func gasDifference() -> Double {
		return programData!.gasOutcome.doubleValue - gasResult()
	}

	//Returns the converted gas amount, which is the gas amount times the gas exchange rate
	func gasConvertedAmount() -> Double {
		return programData!.gasAmount.doubleValue * gasExchangeRate()
	}

	//Returns the exchange rate between the gas unit and the converted gas unit
	func gasExchangeRate() -> Double {
		return gasWeights[programData!.gasConvertedUnit.integerValue] / gasWeights[programData!.gasUnit.integerValue]
	}

	//Returns the converted gas rate, which is the gas rate divided by both the country exchange rate and the gas exchange rate
	func gasConvertedRate() -> Double {
		return (programData!.gasRate.doubleValue / countryExchangeRate()) / gasExchangeRate()
	}

	//Returns the converted gas result, which is the converted gas amount times the converted gas rate
	func gasConvertedResult() -> Double {
		return gasConvertedAmount() * gasConvertedRate()
	}

	//Returns the converted gas outcome, which is the gas outcome divided by the country exchange rate
	func gasConvertedOutcome() -> Double {
		return programData!.gasOutcome.doubleValue / countryExchangeRate()
	}

	//Returns the converted gas difference, which is the converted gas outcome minus the converted gas result
	func gasConvertedDifference() -> Double {
		return gasConvertedOutcome() - gasConvertedResult()
	}

	//Returns the meal tip, which is the meal amount times the meal percentage
	func mealTip() -> Double {
		return programData!.mealAmount.doubleValue * (programData!.mealPercentage.doubleValue / 100)
	}

	//Returns the meal total, which is the meal amount plus the meal tip
	func mealTotal() -> Double {
		return programData!.mealAmount.doubleValue + mealTip()
	}

	//Returns the meal result, which is the meal total divided by the meal people
	func mealResult() -> Double {
		return mealTotal() / programData!.mealPeople.doubleValue
	}

	//Returns the meal difference, which is the meal outcome minus the meal result
	func mealDifference() -> Double {
		return programData!.mealOutcome.doubleValue - mealResult()
	}

	//Returns the converted meal amount, which is the meal amount divided by the country exchange rate
	func mealConvertedAmount() -> Double {
		return programData!.mealAmount.doubleValue / countryExchangeRate()
	}

	//Returns the converted meal tip, which is the converted meal amount times the meal percentage
	func mealConvertedTip() -> Double {
		return mealConvertedAmount() * (programData!.mealPercentage.doubleValue / 100)
	}

	//Returns the converted meal total, which is the converted meal amount plus the converted meal tip
	func mealConvertedTotal() -> Double {
		return mealConvertedAmount() + mealConvertedTip()
	}

	//Returns the converted meal result, which is the converted meal total divided by the meal people
	func mealConvertedResult() -> Double {
		return mealConvertedTotal() / programData!.mealPeople.doubleValue
	}

	//Returns the converted meal outcome, which is the meal outcome divided by the country exchange rate
	func mealConvertedOutcome() -> Double {
		return programData!.mealOutcome.doubleValue / countryExchangeRate()
	}

	//Returns the converted meal differece, which is the converted meal outcome minus the converted meal result
	func mealConvertedDifference() -> Double {
		return mealConvertedOutcome() - mealConvertedResult()
	}

	//Returns the converted amount from the MiscViewController
	func miscConvertedAmount() -> Double {
		if programData!.miscMeasurement == 0 && programData!.miscUnit == 0 {
			return programData!.miscAmount.doubleValue * (25146 / 15625)
		} else if programData!.miscMeasurement == 0 && programData!.miscUnit != 0 {
			return programData!.miscAmount.doubleValue * (15625 / 25146)
		} else if programData!.miscMeasurement != 0 && programData!.miscUnit == 0 {
			return (programData!.miscAmount.doubleValue - 32) * (5 / 9)
		} else {
			return (programData!.miscAmount.doubleValue * (9 / 5)) + 32
		}
	}

	//Triggers a menu to pop up for changing the origin country
	@IBAction func originCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: countryNames.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countryNames[i], style: UIAlertActionStyle.Default, handler: originCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes the origin country based upon the selected choice
	func originCountryAlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: countryNames.count, by: 1) {
			if countryNames[i] == action.title {
				programData!.originCountry = i
				saveProgramData()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing the travel country
	@IBAction func travelCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select a country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		for i in 0.stride(to: countryNames.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countryNames[i], style: UIAlertActionStyle.Default, handler: travelCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	//Changes the travel country based upon the selected choice
	func travelCountryAlertActionHandler(action: UIAlertAction!) {
		for i in 0.stride(to: countryNames.count, by: 1) {
			if countryNames[i] == action.title {
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