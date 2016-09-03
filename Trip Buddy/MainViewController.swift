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
	                                               EqualViewController(nibName: "EqualViewController", bundle: nil)]

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

	//Equal information
	let equalDistanceUnits: [String] = ["Miles (or MPH)", "Kilometers (or km/h)"]

	let equalTemperatureUnits: [String] = ["° Farenheit", "° Celsius"]

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
			existingData[0].equalDistanceAmount = 0
			existingData[0].equalDistanceUnit = 0
			existingData[0].equalTemperatureAmount = 0
			existingData[0].equalTemperatureUnit = 0
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

		updating = true
		saveProgramData()
		request.resume()
	}

	//Given a response, update the exchange rate between the origin country and the travel country
	func countryExchangeRateResponse(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
		var alertReason = ""
		var previousValue = "This program requires a successful internet connection in order to utilize country exchange rates."

		dispatch_async(dispatch_get_main_queue(), {
			self.updating = false
			if urlResponse != nil {
				if (urlResponse as! NSHTTPURLResponse).statusCode == 200 {
					let countryExchangeString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
					if countryExchangeString.componentsSeparatedByString(",").count > 2 {
						let countryExchangeArray = countryExchangeString.componentsSeparatedByString(",")
						if Double(countryExchangeArray[1]) != nil {
							self.programData!.countryExchangeRate = Double(countryExchangeArray[1])!
							self.programData!.countryExchangeDate = countryExchangeArray[2].stringByReplacingOccurrencesOfString("\"", withString: "")
						} else {
							alertReason = "The retrieved data doesn't contain a numeric value. Please try again at a later time. We apologize for the inconvenience."
						}
					} else {
						alertReason = "The retrieved data isn't properly formatted. Please try again at a later time. We apologize for the inconvenience."
					}
				} else {
					alertReason = "One of the countries you selected doesn't seem to have any data currently. Please try a different country for the time being. We apologize for the inconvenience."
				}
			} else {
				alertReason = "Make sure your device is connected to the internet before trying again."
			}
			if self.programData!.countryExchangeRate.doubleValue < 0.01 {
				self.programData!.countryExchangeRate = 0.01
			}
			self.saveProgramData()

			if alertReason == "" {
				//Transition to the help view controller by default when the app first starts
				if self.loading && self.programData!.showHelpAtStartup == 1 {
					self.performSegueWithIdentifier("MainToHelpSegue", sender: self)
				}
			} else {
				//If there is an alert reason, display it
				if self.programData!.countryExchangeDate != "1/1/2000" {
					previousValue = "The previous value (\(String(format: "%.2f", self.programData!.countryExchangeRate.doubleValue))) from \(self.programData!.countryExchangeDate) will be used instead."
				}
				let alertController = UIAlertController(title: "Unable to update the country exchange rate", message: "\(previousValue) \(alertReason)", preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
			}
			self.loading = false
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
		//Relevant equal information
		let equalViewController = viewControllers[3] as! EqualViewController
		let equalDistanceUnit = equalDistanceUnits[programData!.equalDistanceUnit.integerValue]
		let equalEquivalentDistanceUnit = equalDistanceUnits[1 - programData!.equalDistanceUnit.integerValue]
		let equalTemperatureUnit = equalTemperatureUnits[programData!.equalTemperatureUnit.integerValue]
		let equalEquivalentTemperatureUnit = equalTemperatureUnits[1 - programData!.equalTemperatureUnit.integerValue]

		//Update MainViewController's elements
		originCountryImageView.image = UIImage(named: originName)
		originCountryButton.setTitle("Origin Country: \(originName)", forState: UIControlState.Normal)
		originCountryButton.enabled = !updating
		originCountryButton.enabled = false //Get rid of this line for the international version!!!
		travelCountryImageView.image = UIImage(named: travelName)
		travelCountryButton.setTitle("Travel Country: \(travelName)", forState: UIControlState.Normal)
		travelCountryButton.enabled = !updating
		//Update ExchangeViewController's elements
		exchangeViewController.unitsLabel.text = "Exchanging \(originCurrency) to \(travelCurrency):"
		if !updating {
			exchangeViewController.rateLabel.text = "\(originSymbol) 1.00 \(originCurrency) = \(travelSymbol) \(String(format: "%.2f", programData!.countryExchangeRate.doubleValue)) \(travelCurrency)"
		} else {
			exchangeViewController.rateLabel.text = "(Updating...)"
		}
		if programData!.exchangeAmount != 0 {
			exchangeViewController.amountTextField.text = "\(originSymbol) \(String(format: "%.2f", programData!.exchangeAmount.doubleValue)) \(originCurrency)"
		} else {
			exchangeViewController.amountTextField.text = ""
		}
		exchangeViewController.percentagePrefixLabel.hidden = programData!.exchangeAmount == 0
		if programData!.exchangePercentage != 0 {
			exchangeViewController.percentageTextField.text = "\(programData!.exchangePercentage.integerValue) %"
		} else {
			exchangeViewController.percentageTextField.text = ""
		}
		exchangeViewController.percentageTextField.hidden = programData!.exchangeAmount == 0
		exchangeViewController.feePrefixLabel.hidden = programData!.exchangeAmount == 0
		exchangeViewController.feeTextField.text = "\(originSymbol) \(String(format: "%.2f", programData!.exchangeFee.doubleValue)) \(originCurrency)"
		exchangeViewController.feeTextField.hidden = programData!.exchangeAmount == 0
		exchangeViewController.feeTextField.enabled = programData!.exchangePercentage == 0
		exchangeViewController.resultLabel.text = "I should get \(travelSymbol) \(String(format: "%.2f", exchangeResult())) \(travelCurrency) back"
		exchangeViewController.resultLabel.hidden = programData!.exchangeAmount == 0
		exchangeViewController.outcomePrefixLabel.hidden = programData!.exchangeAmount == 0
		if programData!.exchangeOutcome != 0 {
			exchangeViewController.outcomeTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.exchangeOutcome.doubleValue)) \(travelCurrency)"
		} else {
			exchangeViewController.outcomeTextField.text = ""
		}
		exchangeViewController.outcomeTextField.hidden = programData!.exchangeAmount == 0
		if exchangeDifference() == 0 {
			exchangeViewController.differenceLabel.text = "Then it was a fair exchange"
		} else if exchangeDifference() > 0 {
			exchangeViewController.differenceLabel.text = "Then I got \(travelSymbol) \(String(format: "%.2f", exchangeDifference())) \(travelCurrency) more"
		} else {
			exchangeViewController.differenceLabel.text = "Then I got \(travelSymbol) \(String(format: "%.2f", -exchangeDifference())) \(travelCurrency) less"
		}
		exchangeViewController.differenceLabel.hidden = programData!.exchangeOutcome == 0
		exchangeViewController.helpButton.enabled = !updating
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
		//Update EqualViewController's elements
		if programData!.equalDistanceAmount != 0 {
			equalViewController.distanceAmountTextField.text = String(format: "%.3f", programData!.equalDistanceAmount.doubleValue)
		} else {
			equalViewController.distanceAmountTextField.text = ""
		}
		equalViewController.distanceUnitButton.setTitle(equalDistanceUnit, forState: UIControlState.Normal)
		equalViewController.equivalentDistanceAmountLabel.text = String(format: "%.3f", equalEquivalentDistanceAmount())
		equalViewController.equivalentDistanceUnitLabel.text = equalEquivalentDistanceUnit
		if programData!.equalTemperatureAmount != 0 {
			equalViewController.temperatureAmountTextField.text = String(format: "%.3f", programData!.equalTemperatureAmount.doubleValue)
		} else {
			equalViewController.temperatureAmountTextField.text = ""
		}
		equalViewController.temperatureUnitButton.setTitle(equalTemperatureUnit, forState: UIControlState.Normal)
		equalViewController.equivalentTemperatureAmountLabel.text = String(format: "%.3f", equalEquivalentTemperatureAmount())
		equalViewController.equivalentTemperatureUnitLabel.text = equalEquivalentTemperatureUnit
	}

	//Returns the exchange total which is the exchange amount minus the exchange fee
	func exchangeTotal() -> Double {
		return programData!.exchangeAmount.doubleValue - programData!.exchangeFee.doubleValue
	}

	//Returns the exchange result, which is the exchange total times the country exchange rate
	func exchangeResult() -> Double {
		return exchangeTotal() * programData!.countryExchangeRate.doubleValue
	}

	//Returns the exchange difference, which is the exchange outcome minues the exchange result
	func exchangeDifference() -> Double {
		return programData!.exchangeOutcome.doubleValue - Double(String(format: "%.2f", exchangeResult()))!
	}

	//Returns the exchange rate between the gas unit and the gas equivalent unit
	func gasExchangeRate() -> Double {
		return gasWeights[programData!.gasUnit.integerValue] / gasWeights[programData!.gasEquivalentUnit.integerValue]
	}

	//Returns the equivalent gas rate, which is the gas rate times the gas exchange rate, divided by the country exchange rate
	func gasEquivalentRate() -> Double {
		return (programData!.gasRate.doubleValue * gasExchangeRate()) / programData!.countryExchangeRate.doubleValue
	}

	//Returns the gas result, which is the gas rate times the gas amount
	func gasResult() -> Double {
		return programData!.gasRate.doubleValue * programData!.gasAmount.doubleValue
	}

	//Returns the gas difference, which is the gas outcome minus the gas result
	func gasDifference() -> Double {
		return programData!.gasOutcome.doubleValue - Double(String(format: "%.2f", gasResult()))!
	}

	//Returns the equivalent meal amount, which is the meal amount divided by the country exchange rate
	func mealEquivalentAmount() -> Double {
		return programData!.mealAmount.doubleValue / programData!.countryExchangeRate.doubleValue
	}

	//Returns the meal tip, which is the meal amount times the meal percentage
	func mealTip() -> Double {
		return programData!.mealAmount.doubleValue * (programData!.mealPercentage.doubleValue / 100)
	}

	//Returns the equivalent meal tip, which is the meal tip divided by the country exchange rate
	func mealEquivalentTip() -> Double {
		return mealTip() / programData!.countryExchangeRate.doubleValue
	}

	//Returns the meal total, which is the meal amount plus the meal tip
	func mealTotal() -> Double {
		return programData!.mealAmount.doubleValue + mealTip()
	}

	//Returns the equivalent meal total, which is the meal total divided by the country exchange rate
	func mealEquivalentTotal() -> Double {
		return mealTotal() / programData!.countryExchangeRate.doubleValue
	}

	//Returns the meal result, which is the meal total divided by the meal people
	func mealResult() -> Double {
		return mealTotal() / programData!.mealPeople.doubleValue
	}

	//Returns the equivalent meal result, which is the meal result divided by the country exchange rate
	func mealEquivalentResult() -> Double {
		return mealResult() / programData!.countryExchangeRate.doubleValue
	}

	//Returns the equivalent distance amount from the EqualViewController
	func equalEquivalentDistanceAmount() -> Double {
		if programData!.equalDistanceUnit == 0 {
			return programData!.equalDistanceAmount.doubleValue * (25146 / 15625)
		} else {
			return programData!.equalDistanceAmount.doubleValue * (15625 / 25146)
		}
	}

	//Returns the equivalent temperature amount from the EqualViewController
	func equalEquivalentTemperatureAmount() -> Double {
		if programData!.equalTemperatureUnit == 0 {
			return (programData!.equalTemperatureAmount.doubleValue - 32) * (5 / 9)
		} else {
			return (programData!.equalTemperatureAmount.doubleValue * (9 / 5)) + 32
		}
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
			if action.title == countryNames[i] {
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
			if action.title == countryNames[i] {
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