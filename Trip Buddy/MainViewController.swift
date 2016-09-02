//Trip Buddy
//MainViewController.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class MainViewController: UIViewController {
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

	let countrySymbols: [String] = ["$", "€", "лв", "$", "$", "¥", "€", "€",
	                                "₹", "€", "¥", "R", "$", "$", "€", "C",
	                                "£", "$"]

	let countryAbbreviations: [String] = ["ARS", "EUR", "BGN", "CAD", "CLP", "CNY", "EUR", "EUR",
	                                      "INR", "EUR", "JPY", "MYR", "MXN", "SGD", "EUR", "CHF",
	                                      "GBP", "USD"]

	//Gas information
	let gasUnits: [String] = ["U.S. Gallon", "Imp. Gallon", "Liter"]

	let gasWeights: [Double] = [1000000000, 832673840, 3785411784]

	//Miscellaneous information
	let miscDistanceUnits: [String] = ["Miles (or MPH)", "Kilometers (or km/h)"]

	let miscTemperatureUnits: [String] = ["° Farenheit", "° Celsius"]

	//CoreData variables for saving program data
	let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var programData: ProgramData? = nil

	//Runtime variables
	var updating = false
	var loading = true

	//This code is executed when the view is first loaded
	override func viewDidLoad() {
		super.viewDidLoad()
		var existingData: [ProgramData] = []

		//Initialize each of the view controllers and add them into the scroll view
		for i in 0.stride(to: viewControllers.count, by: 1) {
			viewControllers[i].view.frame.size.height = scrollView.bounds.height
			viewControllers[i].view.frame.origin.x = view.frame.size.width * CGFloat(i)
			scrollView.addSubview(viewControllers[i].view)
			viewControllers[i].mainViewController = self
		}
		//Access the program data from CoreData
		do {
			existingData = try context.executeFetchRequest(NSFetchRequest(entityName: "ProgramData")) as! [ProgramData]
		} catch _ as NSError {}
		//If valid program data doesn't exist, create a default instance instead
		if existingData.count != 1 {
			for i in (existingData.count - 1).stride(through: 0, by: -1) {
				context.deleteObject(existingData[i] as NSManagedObject)
				existingData.removeAtIndex(i)
			}
			existingData = [NSEntityDescription.insertNewObjectForEntityForName("ProgramData", inManagedObjectContext: context) as! ProgramData]
			existingData[0].originCountry = countryNames.count - 1
			existingData[0].travelCountry = countryNames.count - 2
			existingData[0].countryExchangeRate = 1
			existingData[0].countryExchangeDate = "1/1/2000"
			existingData[0].showHelpAtStartup = 1
			existingData[0].exchangeAmount = 0
			existingData[0].exchangePercentage = 0
			existingData[0].exchangeFee = 0
			existingData[0].exchangeOutcome = 0
			existingData[0].gasUnit = 1
			existingData[0].gasEquivalentUnit = 0
			existingData[0].gasRate = 0
			existingData[0].gasAmount = 0
			existingData[0].gasOutcome = 0
			existingData[0].mealAmount = 0
			existingData[0].mealPercentage = 0
			existingData[0].mealPeople = 1
			existingData[0].miscDistanceAmount = 0
			existingData[0].miscDistanceUnit = 0
			existingData[0].miscTemperatureAmount = 0
			existingData[0].miscTemperatureUnit = 0
		}
		programData = existingData[0]
		//Once program data is obtained, update the country exchange rate, save all data, and update all UI elements
		countryExchangeRateRequest()
	}

	//Makes a request for the exchange rate between the origin country and the travel country
	func countryExchangeRateRequest() {
		let originAbbreviation = countryAbbreviations[programData!.originCountry.integerValue]
		let travelAbbreviation = countryAbbreviations[programData!.travelCountry.integerValue]
		let url = NSURL(string: "https://download.finance.yahoo.com/d/quotes.csv?s=\(originAbbreviation)\(travelAbbreviation)=X&f=nl1d1t1")
		let request = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: countryExchangeRateResponse)

		originCountryButton.enabled = false
		travelCountryButton.enabled = false
		updating = true
		saveProgramData()
		request.resume()
	}

	//Given a response, update the exchange rate between the origin country and the travel country
	func countryExchangeRateResponse(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
		dispatch_async(dispatch_get_main_queue(), {
			self.originCountryButton.enabled = true
			self.travelCountryButton.enabled = true
			self.updating = false
			if urlResponse != nil {
				if (urlResponse as! NSHTTPURLResponse).statusCode == 200 {
					let countryExchangeString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
					if countryExchangeString.componentsSeparatedByString(",").count > 1 {
						let countryExchangeArray = countryExchangeString.componentsSeparatedByString(",")
						if Double(countryExchangeArray[1]) != nil {
							self.programData!.countryExchangeRate = Double(countryExchangeArray[1])!
						} else {
							let alertController = UIAlertController(title: "Error", message: "Unable to update the country exchange rate. The previous value will be used instead. The retrieved data doesn't contain a numeric value. Please try again at a later time. We apologize for the inconvenience.", preferredStyle: UIAlertControllerStyle.Alert)
							alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
							self.presentViewController(alertController, animated: true, completion: nil)
						}
					} else {
						let alertController = UIAlertController(title: "Error", message: "Unable to update the country exchange rate. The previous value will be used instead. The retrieved data isn't properly formatted. Please try again at a later time. We apologize for the inconvenience.", preferredStyle: UIAlertControllerStyle.Alert)
						alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
						self.presentViewController(alertController, animated: true, completion: nil)
					}
				} else {
					let alertController = UIAlertController(title: "Error", message: "Unable to update the country exchange rate. The previous value will be used instead. One of the countries you selected doesn't seem to have any data currently. Please try a different country for the time being. We apologize for the inconvenience.", preferredStyle: UIAlertControllerStyle.Alert)
					alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
					self.presentViewController(alertController, animated: true, completion: nil)
				}
			} else {
				let alertController = UIAlertController(title: "Error", message: "Unable to update the country exchange rate. The previous value will be used instead. Make sure your device is connected to the internet before trying again.", preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
			if self.programData!.countryExchangeRate.doubleValue < 0.01 {
				self.programData!.countryExchangeRate = 0.01
			}
			self.saveProgramData()
		})
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
		let gasUnit = gasUnits[programData!.gasUnit.integerValue]
		let gasEquivalentUnit = gasUnits[programData!.gasEquivalentUnit.integerValue]
		//Relevant meal information
		let mealViewController = viewControllers[2] as! MealViewController
		//Relevant miscellaneous information
		let miscViewController = viewControllers[3] as! MiscViewController
		let miscDistanceUnit = miscDistanceUnits[programData!.miscDistanceUnit.integerValue]
		let miscEquivalentDistanceUnit = miscDistanceUnits[1 - programData!.miscDistanceUnit.integerValue]
		let miscTemperatureUnit = miscTemperatureUnits[programData!.miscTemperatureUnit.integerValue]
		let miscEquivalentTemperatureUnit = miscTemperatureUnits[1 - programData!.miscTemperatureUnit.integerValue]

		//Update MainViewController's elements
		originCountryImageView.image = UIImage(named: originName)
		originCountryButton.setTitle("Origin Country: \(originName)", forState: UIControlState.Normal)
		travelCountryImageView.image = UIImage(named: travelName)
		travelCountryButton.setTitle("Travel Country: \(travelName)", forState: UIControlState.Normal)
		//Update ExchangeViewController's elements
		exchangeViewController.unitsLabel.text = "Exchanging \(originCurrency) to \(travelCurrency):"
		if !updating {
			exchangeViewController.rateLabel.text = "\(originSymbol) 1.00 = \(travelSymbol) \(String(format: "%.2f", programData!.countryExchangeRate.doubleValue))"
		} else {
			exchangeViewController.rateLabel.text = "(Updating...)"
		}
		exchangeViewController.amountTextField.text = String(format: "%.2f", programData!.exchangeAmount.doubleValue)
		exchangeViewController.amountUnitLabel.text = originCurrency
		exchangeViewController.percentageTextField.text = String(format: "%.2f", programData!.exchangePercentage.doubleValue)
		exchangeViewController.feeLabel.text = "(which equals \(originSymbol) \(String(format: "%.2f", exchangeFee())) \(originCurrency))"
		exchangeViewController.totalLabel.text = "then out of \(originSymbol) \(String(format: "%.2f", exchangeTotal())) \(originCurrency)"
		exchangeViewController.resultLabel.text = "I should get \(travelSymbol) \(String(format: "%.2f", exchangeResult())) \(travelCurrency) back"
		exchangeViewController.outcomeTextField.text = String(format: "%.2f", programData!.exchangeOutcome.doubleValue)
		exchangeViewController.outcomeUnitLabel.text = travelCurrency
		if exchangeDifference() == 0 {
			exchangeViewController.differenceLabel.text = "then it was a fair exchange"
		} else if exchangeDifference() > 0 {
			exchangeViewController.differenceLabel.text = "then I got \(travelSymbol) \(String(format: "%.2f", exchangeDifference())) \(travelCurrency) more"
		} else {
			exchangeViewController.differenceLabel.text = "then I got \(travelSymbol) \(String(format: "%.2f", -exchangeDifference())) \(travelCurrency) less"
		}
		//Update GasViewController's elements
		gasViewController.unitButton.setTitle("\(gasUnit)s", forState: UIControlState.Normal)
		gasViewController.unitButton.enabled = !updating
		gasViewController.equivalentUnitButton.setTitle("\(gasEquivalentUnit)s", forState: UIControlState.Normal)
		gasViewController.equivalentUnitButton.enabled = !updating
		gasViewController.equivalentUnitButton.enabled = false //Get rid of this line for the international version!!!
		gasViewController.ratePrefixLabel.text = "Today's price/\(gasUnit):"
		if programData!.gasRate != 0 {
			gasViewController.rateTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.gasRate.doubleValue)) \(travelCurrency)"
		} else {
			gasViewController.rateTextField.text = ""
		}
		gasViewController.equivalentRateLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", gasEquivalentRate())) \(originCurrency)/\(gasEquivalentUnit))"
		gasViewController.equivalentRateLabel.hidden = programData!.gasRate == 0
		gasViewController.amountPrefixLabel.hidden = programData!.gasRate == 0
		if programData!.gasAmount != 0 {
			gasViewController.amountTextField.text = "\(String(format: "%.2f", programData!.gasAmount.doubleValue)) \(gasUnit)s"
		} else {
			gasViewController.amountTextField.text = ""
		}
		gasViewController.amountTextField.hidden = programData!.gasRate == 0
		gasViewController.resultLabel.text = "Then I should pay \(travelSymbol) \(String(format: "%.2f", gasResult())) \(travelCurrency)"
		gasViewController.resultLabel.hidden = programData!.gasAmount == 0
		gasViewController.outcomePrefixLabel.hidden = programData!.gasAmount == 0
		if programData!.gasOutcome != 0 {
			gasViewController.outcomeTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.gasOutcome.doubleValue)) \(travelCurrency)"
		} else {
			gasViewController.outcomeTextField.text = ""
		}
		gasViewController.outcomeTextField.hidden = programData!.gasAmount == 0
		if gasDifference() == 0 {
			gasViewController.differenceLabel.text = "Then it was a fair transaction"
		} else if gasDifference() > 0 {
			gasViewController.differenceLabel.text = "Then I overpaid by \(travelSymbol) \(String(format: "%.2f", gasDifference())) \(travelCurrency)"
		} else {
			gasViewController.differenceLabel.text = "Then I saved \(travelSymbol) \(String(format: "%.2f", -gasDifference())) \(travelCurrency)"
		}
		gasViewController.differenceLabel.hidden = programData!.gasOutcome == 0
		//Update MealViewController's elements
		if programData!.mealAmount != 0 {
			mealViewController.amountTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.mealAmount.doubleValue)) \(travelCurrency)"
		} else {
			mealViewController.amountTextField.text = ""
		}
		mealViewController.equivalentAmountLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentAmount())) \(originCurrency))"
		mealViewController.equivalentAmountLabel.hidden = programData!.mealAmount == 0
		mealViewController.percentagePrefixLabel.hidden = programData!.mealAmount == 0
		if programData!.mealPercentage != 0 {
			mealViewController.percentageTextField.text = "\(programData!.mealPercentage.integerValue) %"
		} else {
			mealViewController.percentageTextField.text = ""
		}
		mealViewController.percentageTextField.hidden = programData!.mealAmount == 0
		mealViewController.tipLabel.text = "Total tip is \(travelSymbol) \(String(format: "%.2f", mealTip())) \(travelCurrency)"
		mealViewController.tipLabel.hidden = programData!.mealAmount == 0
		mealViewController.equivalentTipLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentTip())) \(originCurrency))"
		mealViewController.equivalentTipLabel.hidden = programData!.mealAmount == 0
		mealViewController.totalLabel.text = "For a total of \(travelSymbol) \(String(format: "%.2f", mealTotal())) \(travelCurrency)"
		mealViewController.totalLabel.hidden = programData!.mealAmount == 0
		mealViewController.equivalentTotalLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentTotal())) \(originCurrency))"
		mealViewController.equivalentTotalLabel.hidden = programData!.mealAmount == 0
		mealViewController.peoplePrefixLabel.hidden = programData!.mealAmount == 0
		if programData!.mealPeople != 1 {
			mealViewController.peopleTextField.text = "\(programData!.mealPeople.integerValue) people"
		} else {
			mealViewController.peopleTextField.text = ""
		}
		mealViewController.peopleTextField.hidden = programData!.mealAmount == 0
		mealViewController.resultLabel.text = "Each person pays \(travelSymbol) \(String(format: "%.2f", mealResult())) \(travelCurrency)"
		mealViewController.resultLabel.hidden = programData!.mealPeople == 1
		mealViewController.equivalentResultLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentResult())) \(originCurrency))"
		mealViewController.equivalentResultLabel.hidden = programData!.mealPeople == 1
		//Update MiscViewController's elements
		if programData!.miscDistanceAmount != 0 {
			miscViewController.distanceAmountTextField.text = String(format: "%.3f", programData!.miscDistanceAmount.doubleValue)
		} else {
			miscViewController.distanceAmountTextField.text = ""
		}
		miscViewController.distanceUnitButton.setTitle(miscDistanceUnit, forState: UIControlState.Normal)
		miscViewController.equivalentDistanceAmountLabel.text = "equals \(String(format: "%.3f", miscEquivalentDistanceAmount()))"
		miscViewController.equivalentDistanceUnitLabel.text = miscEquivalentDistanceUnit
		if programData!.miscTemperatureAmount != 0 {
			miscViewController.temperatureAmountTextField.text = String(format: "%.3f", programData!.miscTemperatureAmount.doubleValue)
		} else {
			miscViewController.temperatureAmountTextField.text = ""
		}
		miscViewController.temperatureUnitButton.setTitle(miscTemperatureUnit, forState: UIControlState.Normal)
		miscViewController.equivalentTemperatureAmountLabel.text = "equals \(String(format: "%.3f", miscEquivalentTemperatureAmount()))"
		miscViewController.equivalentTemperatureUnitLabel.text = miscEquivalentTemperatureUnit
	}

	//Returns the exchange fee, which is the exchange amount times the exchange percentage
	func exchangeFee() -> Double {
		return programData!.exchangeAmount.doubleValue * (programData!.exchangePercentage.doubleValue / 100)
	}

	//Returns the exchange total which is the exchange amount minus the exchange fee
	func exchangeTotal() -> Double {
		return programData!.exchangeAmount.doubleValue - exchangeFee()
	}

	//Returns the exchange result, which is the exchange total times the country exchange rate
	func exchangeResult() -> Double {
		return Double(String(format: "%.2f", exchangeTotal() * programData!.countryExchangeRate.doubleValue))!
	}

	//Returns the exchange difference, which is the exchange outcome minues the exchange result
	func exchangeDifference() -> Double {
		return programData!.exchangeOutcome.doubleValue - exchangeResult()
	}

	//Returns the exchange rate between the gas unit and the gas equivalent unit
	func gasExchangeRate() -> Double {
		return gasWeights[programData!.gasUnit.integerValue] / gasWeights[programData!.gasEquivalentUnit.integerValue]
	}

	//Returns the equivalent gas rate, which is the gas rate divided by both the country exchange rate and the gas exchange rate
	func gasEquivalentRate() -> Double {
		return (programData!.gasRate.doubleValue * gasExchangeRate() / programData!.countryExchangeRate.doubleValue)
	}

	//Returns the gas result, which is the gas amount times the gas rate
	func gasResult() -> Double {
		return Double(String(format: "%.2f", programData!.gasRate.doubleValue * programData!.gasAmount.doubleValue))!
	}

	//Returns the gas difference, which is the gas outcome minus the gas result
	func gasDifference() -> Double {
		return programData!.gasOutcome.doubleValue - gasResult()
	}

	//Returns the equivalent meal amount, which is the meal amount divided by the country exchange rate
	func mealEquivalentAmount() -> Double {
		return programData!.mealAmount.doubleValue / programData!.countryExchangeRate.doubleValue
	}

	//Returns the meal tip, which is the meal amount times the meal percentage
	func mealTip() -> Double {
		return programData!.mealAmount.doubleValue * (programData!.mealPercentage.doubleValue / 100)
	}

	//Returns the equivalent meal tip, which is the equivalent meal amount times the meal percentage
	func mealEquivalentTip() -> Double {
		return mealEquivalentAmount() * (programData!.mealPercentage.doubleValue / 100)
	}

	//Returns the meal total, which is the meal amount plus the meal tip
	func mealTotal() -> Double {
		return programData!.mealAmount.doubleValue + mealTip()
	}

	//Returns the equivalent meal total, which is the equivalent meal amount plus the equivalent meal tip
	func mealEquivalentTotal() -> Double {
		return mealEquivalentAmount() + mealEquivalentTip()
	}

	//Returns the meal result, which is the meal total divided by the meal people
	func mealResult() -> Double {
		return Double(String(format: "%.2f", mealTotal() / programData!.mealPeople.doubleValue))!
	}

	//Returns the equivalent meal result, which is the meal result divided by the country exchange rate
	func mealEquivalentResult() -> Double {
		return mealResult() / programData!.countryExchangeRate.doubleValue
	}

	//Returns the equivalent distance amount from the MiscViewController
	func miscEquivalentDistanceAmount() -> Double {
		if programData!.miscDistanceUnit == 0 {
			return programData!.miscDistanceAmount.doubleValue * (25146 / 15625)
		} else {
			return programData!.miscDistanceAmount.doubleValue * (15625 / 25146)
		}
	}

	//Returns the equivalent temperature amount from the MiscViewController
	func miscEquivalentTemperatureAmount() -> Double {
		if programData!.miscTemperatureUnit == 0 {
			return (programData!.miscTemperatureAmount.doubleValue - 32) * (5 / 9)
		} else {
			return (programData!.miscTemperatureAmount.doubleValue * (9 / 5)) + 32
		}
	}

	//Transition to the help view controller by default when the app first starts
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if programData!.showHelpAtStartup == 1 && loading {
			performSegueWithIdentifier("MainToHelpSegue", sender: self)
		}
		loading = false
	}

	//Set the scroll view's content size once all of the sub-views have been loaded and resized
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scrollView.contentSize = CGSizeMake(view.frame.size.width * CGFloat(viewControllers.count), scrollView.bounds.height)
	}

	//This code is executed whenever a segue is about to take place
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "MainToHelpSegue" {
			let helpViewController = segue.destinationViewController as! HelpViewController
			helpViewController.mainViewController = self
		}
	}

	//Triggers a menu to pop up for changing the origin country
	@IBAction func originCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select your origin country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		view.endEditing(true) //Close any open responder beforehand
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
				countryExchangeRateRequest()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing the travel country
	@IBAction func travelCountryButtonPressed(sender: AnyObject) {
		let alertController = UIAlertController(title: "Select your travel country:", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

		view.endEditing(true) //Close any open responder beforehand
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
				countryExchangeRateRequest()
				break
			}
		}
	}

	//Changes the scroll view depending upon what bottom button was pressed
	@IBAction func bottomButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder beforehand
		scrollView.contentOffset = CGPointMake(view.frame.size.width * CGFloat(sender.tag), 0)
	}
}