//Trip Buddy
//MainViewController.swift
//(c) 2018 Kaiyode Software

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
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var programData: ProgramData? = nil

	//Runtime variables
	var updating = false
	var loading = true

	//This code is executed when the view is first loaded
	override func viewDidLoad() {
		super.viewDidLoad()
		var existingData: [ProgramData] = []

		//Initialize each of the view controllers and add them into the scroll view
		for i in stride(from: 0, to: viewControllers.count, by: 1) {
			viewControllers[i].view.frame.size.height = scrollView.bounds.height
			viewControllers[i].view.frame.origin.x = view.frame.size.width * CGFloat(i)
			scrollView.addSubview(viewControllers[i].view)
			viewControllers[i].mainViewController = self
		}
		//Access the program data from CoreData
		do {
			existingData = try context.fetch(NSFetchRequest(entityName: "ProgramData")) as! [ProgramData]
		} catch {}
		//If valid program data doesn't exist, create a default instance instead
		if existingData.count != 1 {
			for i in stride(from: existingData.count - 1, through: 0, by: -1) {
				context.delete(existingData[i] as NSManagedObject)
				existingData.remove(at: i)
			}
			existingData = [NSEntityDescription.insertNewObject(forEntityName: "ProgramData", into: context) as! ProgramData]
			existingData[0].originCountry = countryNames.count - 1
			existingData[0].travelCountry = countryNames.count - 2
			existingData[0].countryExchangeRate = 1
			existingData[0].countryExchangeDate = "2000-01-01 00:00:00"
			existingData[0].showHelpAtStartup = true
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
		let originAbbreviation = countryAbbreviations[programData!.originCountry]
		let travelAbbreviation = countryAbbreviations[programData!.travelCountry]
		let url = URL(string: "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=\(originAbbreviation)&to_currency=\(travelAbbreviation)&apikey=GWQJ4U9KX9O20ESK")
		let request = URLSession.shared.dataTask(with: url!, completionHandler: countryExchangeRateResponse)

		updating = true
		saveProgramData()
		request.resume()
	}

	//Given a response, update the exchange rate between the origin country and the travel country
	func countryExchangeRateResponse(data: Data?, urlResponse: URLResponse?, error: Error?) {
		var alertReason = ""
		var previousValue = ""

		DispatchQueue.main.async {
			self.updating = false
			if urlResponse != nil {
				if (urlResponse as! HTTPURLResponse).statusCode == 200 {
					do {
						let countryExchangeJSONObject = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
						let countryExchangeDictionary = countryExchangeJSONObject["Realtime Currency Exchange Rate"] as? [String : Any]
						if countryExchangeDictionary != nil {
							let countryExchangeString = countryExchangeDictionary!["5. Exchange Rate"] as? String
							let countryExchangeDate = countryExchangeDictionary!["6. Last Refreshed"] as? String
							if countryExchangeString != nil && Double(countryExchangeString!) != nil && countryExchangeDate != nil {
								self.programData!.countryExchangeRate = Double(countryExchangeString!)!
								self.programData!.countryExchangeDate = countryExchangeDate!
							} else {
								alertReason = "The retrieved data contains illegitimate values. Please try again at a later time. We apologize for the inconvenience."
							}
						} else {
							alertReason = "One of the selected countries doesn't currently have any exchange rate data. Please try again at a later time. We apologize for the inconvenience."
						}
					} catch {
						alertReason = "The retrieved data isn't properly formatted. Please try again at a later time. We apologize for the inconvenience."
					}
				} else {
					alertReason = "The web service for exchange rates is currently offline. Please try again at a later time. We apologize for the inconvenience."
				}
			} else {
				alertReason = "Make sure your device is connected to the internet before trying again."
			}
			if self.programData!.countryExchangeRate < 0.01 {
				self.programData!.countryExchangeRate = 0.01
			}
			self.saveProgramData()
			if alertReason == "" {
				//Transition to the help view controller by default when the app first starts
				if self.loading && self.programData!.showHelpAtStartup {
					self.performSegue(withIdentifier: "MainToHelpSegue", sender: self)
				}
			} else {
				//If there is an alert reason, display it
				if self.programData!.countryExchangeDate != "2000-01-01 00:00:00" {
					previousValue = "The previous value (\(String(format: "%.2f", self.programData!.countryExchangeRate))) from \(self.programData!.countryExchangeDate) UTC will be used instead."
				} else {
					previousValue = "This app requires at least one successful internet connection in order to utilize country exchange rates."
				}
				let alertController = UIAlertController(title: "Unable to update the country exchange rate", message: "\(previousValue) \(alertReason)", preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
			self.loading = false
		}
	}

	//Saves the program data to CoreData and then updates all of the UI elements
	func saveProgramData() {
		do {
			try context.save()
		} catch {}

		//Relevant country information
		let originName = countryNames[programData!.originCountry]
		let originCurrency = countryCurrencies[programData!.originCountry]
		let originSymbol = countrySymbols[programData!.originCountry]
		let travelName = countryNames[programData!.travelCountry]
		let travelCurrency = countryCurrencies[programData!.travelCountry]
		let travelSymbol = countrySymbols[programData!.travelCountry]
		//Relevant exchange information
		let exchangeViewController = viewControllers[0] as! ExchangeViewController
		//Relevant gas information
		let gasViewController = viewControllers[1] as! GasViewController
		let gasUnit = gasUnits[programData!.gasUnit]
		let gasEquivalentUnit = gasUnits[programData!.gasEquivalentUnit]
		//Relevant meal information
		let mealViewController = viewControllers[2] as! MealViewController
		//Relevant equal information
		let equalViewController = viewControllers[3] as! EqualViewController
		let equalDistanceUnit = equalDistanceUnits[programData!.equalDistanceUnit]
		let equalEquivalentDistanceUnit = equalDistanceUnits[1 - programData!.equalDistanceUnit]
		let equalTemperatureUnit = equalTemperatureUnits[programData!.equalTemperatureUnit]
		let equalEquivalentTemperatureUnit = equalTemperatureUnits[1 - programData!.equalTemperatureUnit]

		//Update MainViewController's elements
		originCountryImageView.image = UIImage(named: originName)
		originCountryButton.setTitle("Origin Country: \(originName)", for: UIControlState.normal)
		originCountryButton.isEnabled = !updating
		originCountryButton.isEnabled = false //Get rid of this line for the international version!!!
		travelCountryImageView.image = UIImage(named: travelName)
		travelCountryButton.setTitle("Travel Country: \(travelName)", for: UIControlState.normal)
		travelCountryButton.isEnabled = !updating
		//Update ExchangeViewController's elements
		exchangeViewController.unitsLabel.text = "Exchanging \(originCurrency) to \(travelCurrency):"
		if !updating {
			exchangeViewController.rateLabel.text = "\(originSymbol) 1.00 \(originCurrency) = \(travelSymbol) \(String(format: "%.2f", programData!.countryExchangeRate)) \(travelCurrency)"
		} else {
			exchangeViewController.rateLabel.text = "(Updating...)"
		}
		if programData!.exchangeAmount != 0 {
			exchangeViewController.amountTextField.text = "\(originSymbol) \(String(format: "%.2f", programData!.exchangeAmount)) \(originCurrency)"
		} else {
			exchangeViewController.amountTextField.text = ""
		}
		exchangeViewController.percentagePrefixLabel.isHidden = programData!.exchangeAmount == 0
		if programData!.exchangePercentage != 0 {
			exchangeViewController.percentageTextField.text = "\(programData!.exchangePercentage) %"
			exchangeViewController.feeTextField.textColor = UIColor.gray
		} else {
			exchangeViewController.percentageTextField.text = ""
			exchangeViewController.feeTextField.textColor = UIColor.black
		}
		exchangeViewController.percentageTextField.isHidden = programData!.exchangeAmount == 0
		exchangeViewController.feePrefixLabel.isHidden = programData!.exchangeAmount == 0
		exchangeViewController.feeTextField.text = "\(originSymbol) \(String(format: "%.2f", programData!.exchangeFee)) \(originCurrency)"
		exchangeViewController.feeTextField.isHidden = programData!.exchangeAmount == 0
		exchangeViewController.feeTextField.isEnabled = programData!.exchangePercentage == 0
		exchangeViewController.resultLabel.text = "I should get \(travelSymbol) \(String(format: "%.2f", exchangeResult())) \(travelCurrency) back"
		exchangeViewController.resultLabel.isHidden = programData!.exchangeAmount == 0
		exchangeViewController.outcomePrefixLabel.isHidden = programData!.exchangeAmount == 0
		if programData!.exchangeOutcome != 0 {
			exchangeViewController.outcomeTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.exchangeOutcome)) \(travelCurrency)"
		} else {
			exchangeViewController.outcomeTextField.text = ""
		}
		exchangeViewController.outcomeTextField.isHidden = programData!.exchangeAmount == 0
		if exchangeDifference() == 0 {
			exchangeViewController.differenceLabel.text = "Then it was a fair exchange"
		} else if exchangeDifference() > 0 {
			exchangeViewController.differenceLabel.text = "Then I got \(travelSymbol) \(String(format: "%.2f", exchangeDifference())) \(travelCurrency) more"
		} else {
			exchangeViewController.differenceLabel.text = "Then I got \(travelSymbol) \(String(format: "%.2f", -exchangeDifference())) \(travelCurrency) less"
		}
		exchangeViewController.differenceLabel.isHidden = programData!.exchangeOutcome == 0
		exchangeViewController.helpButton.isEnabled = !updating
		//Update GasViewController's elements
		gasViewController.unitButton.setTitle("\(gasUnit)s", for: UIControlState.normal)
		gasViewController.unitButton.isEnabled = !updating
		gasViewController.equivalentUnitButton.setTitle("\(gasEquivalentUnit)s", for: UIControlState.normal)
		gasViewController.equivalentUnitButton.isEnabled = !updating
		gasViewController.equivalentUnitButton.isEnabled = false //Get rid of this line for the international version!!!
		gasViewController.ratePrefixLabel.text = "Today's price/\(gasUnit):"
		if programData!.gasRate != 0 {
			gasViewController.rateTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.gasRate)) \(travelCurrency)"
		} else {
			gasViewController.rateTextField.text = ""
		}
		gasViewController.equivalentRateLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", gasEquivalentRate())) \(originCurrency)/\(gasEquivalentUnit))"
		gasViewController.equivalentRateLabel.isHidden = programData!.gasRate == 0
		gasViewController.amountPrefixLabel.isHidden = programData!.gasRate == 0
		if programData!.gasAmount != 0 {
			gasViewController.amountTextField.text = "\(String(format: "%.2f", programData!.gasAmount)) \(gasUnit)s"
		} else {
			gasViewController.amountTextField.text = ""
		}
		gasViewController.amountTextField.isHidden = programData!.gasRate == 0
		gasViewController.resultLabel.text = "Then I should pay \(travelSymbol) \(String(format: "%.2f", gasResult())) \(travelCurrency)"
		gasViewController.resultLabel.isHidden = programData!.gasAmount == 0
		gasViewController.outcomePrefixLabel.isHidden = programData!.gasAmount == 0
		if programData!.gasOutcome != 0 {
			gasViewController.outcomeTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.gasOutcome)) \(travelCurrency)"
		} else {
			gasViewController.outcomeTextField.text = ""
		}
		gasViewController.outcomeTextField.isHidden = programData!.gasAmount == 0
		if gasDifference() == 0 {
			gasViewController.differenceLabel.text = "Then it was a fair transaction"
		} else if gasDifference() > 0 {
			gasViewController.differenceLabel.text = "Then I overpaid by \(travelSymbol) \(String(format: "%.2f", gasDifference())) \(travelCurrency)"
		} else {
			gasViewController.differenceLabel.text = "Then I saved \(travelSymbol) \(String(format: "%.2f", -gasDifference())) \(travelCurrency)"
		}
		gasViewController.differenceLabel.isHidden = programData!.gasOutcome == 0
		//Update MealViewController's elements
		if programData!.mealAmount != 0 {
			mealViewController.amountTextField.text = "\(travelSymbol) \(String(format: "%.2f", programData!.mealAmount)) \(travelCurrency)"
		} else {
			mealViewController.amountTextField.text = ""
		}
		mealViewController.equivalentAmountLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentAmount())) \(originCurrency))"
		mealViewController.equivalentAmountLabel.isHidden = programData!.mealAmount == 0
		mealViewController.percentagePrefixLabel.isHidden = programData!.mealAmount == 0
		if programData!.mealPercentage != 0 {
			mealViewController.percentageTextField.text = "\(programData!.mealPercentage) %"
		} else {
			mealViewController.percentageTextField.text = ""
		}
		mealViewController.percentageTextField.isHidden = programData!.mealAmount == 0
		mealViewController.tipLabel.text = "Total tip is \(travelSymbol) \(String(format: "%.2f", mealTip())) \(travelCurrency)"
		mealViewController.tipLabel.isHidden = programData!.mealAmount == 0
		mealViewController.equivalentTipLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentTip())) \(originCurrency))"
		mealViewController.equivalentTipLabel.isHidden = programData!.mealAmount == 0
		mealViewController.totalLabel.text = "For a total of \(travelSymbol) \(String(format: "%.2f", mealTotal())) \(travelCurrency)"
		mealViewController.totalLabel.isHidden = programData!.mealAmount == 0
		mealViewController.equivalentTotalLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentTotal())) \(originCurrency))"
		mealViewController.equivalentTotalLabel.isHidden = programData!.mealAmount == 0
		mealViewController.peoplePrefixLabel.isHidden = programData!.mealAmount == 0
		if programData!.mealPeople != 1 {
			mealViewController.peopleTextField.text = "\(programData!.mealPeople) People"
		} else {
			mealViewController.peopleTextField.text = ""
		}
		mealViewController.peopleTextField.isHidden = programData!.mealAmount == 0
		mealViewController.resultLabel.text = "Each person pays \(travelSymbol) \(String(format: "%.2f", mealResult())) \(travelCurrency)"
		mealViewController.resultLabel.isHidden = programData!.mealPeople == 1
		mealViewController.equivalentResultLabel.text = "(Which is \(originSymbol) \(String(format: "%.2f", mealEquivalentResult())) \(originCurrency))"
		mealViewController.equivalentResultLabel.isHidden = programData!.mealPeople == 1
		//Update EqualViewController's elements
		if programData!.equalDistanceAmount != 0 {
			equalViewController.distanceAmountTextField.text = String(format: "%.3f", programData!.equalDistanceAmount)
		} else {
			equalViewController.distanceAmountTextField.text = ""
		}
		equalViewController.distanceUnitButton.setTitle(equalDistanceUnit, for: UIControlState.normal)
		equalViewController.equivalentDistanceAmountLabel.text = String(format: "%.3f", equalEquivalentDistanceAmount())
		equalViewController.equivalentDistanceUnitLabel.text = equalEquivalentDistanceUnit
		if programData!.equalTemperatureAmount != 0 {
			equalViewController.temperatureAmountTextField.text = String(format: "%.3f", programData!.equalTemperatureAmount)
		} else {
			equalViewController.temperatureAmountTextField.text = ""
		}
		equalViewController.temperatureUnitButton.setTitle(equalTemperatureUnit, for: UIControlState.normal)
		equalViewController.equivalentTemperatureAmountLabel.text = String(format: "%.3f", equalEquivalentTemperatureAmount())
		equalViewController.equivalentTemperatureUnitLabel.text = equalEquivalentTemperatureUnit
	}

	//Returns the exchange total which is the exchange amount minus the exchange fee
	func exchangeTotal() -> Double {
		return programData!.exchangeAmount - programData!.exchangeFee
	}

	//Returns the exchange result, which is the exchange total times the country exchange rate
	func exchangeResult() -> Double {
		return exchangeTotal() * programData!.countryExchangeRate
	}

	//Returns the exchange difference, which is the exchange outcome minues the exchange result
	func exchangeDifference() -> Double {
		return programData!.exchangeOutcome - Double(String(format: "%.2f", exchangeResult()))!
	}

	//Returns the exchange rate between the gas unit and the gas equivalent unit
	func gasExchangeRate() -> Double {
		return gasWeights[programData!.gasUnit] / gasWeights[programData!.gasEquivalentUnit]
	}

	//Returns the equivalent gas rate, which is the gas rate times the gas exchange rate, divided by the country exchange rate
	func gasEquivalentRate() -> Double {
		return (programData!.gasRate * gasExchangeRate()) / programData!.countryExchangeRate
	}

	//Returns the gas result, which is the gas rate times the gas amount
	func gasResult() -> Double {
		return programData!.gasRate * programData!.gasAmount
	}

	//Returns the gas difference, which is the gas outcome minus the gas result
	func gasDifference() -> Double {
		return programData!.gasOutcome - Double(String(format: "%.2f", gasResult()))!
	}

	//Returns the equivalent meal amount, which is the meal amount divided by the country exchange rate
	func mealEquivalentAmount() -> Double {
		return programData!.mealAmount / programData!.countryExchangeRate
	}

	//Returns the meal tip, which is the meal amount times the meal percentage
	func mealTip() -> Double {
		return programData!.mealAmount * (Double(programData!.mealPercentage) / 100)
	}

	//Returns the equivalent meal tip, which is the meal tip divided by the country exchange rate
	func mealEquivalentTip() -> Double {
		return mealTip() / programData!.countryExchangeRate
	}

	//Returns the meal total, which is the meal amount plus the meal tip
	func mealTotal() -> Double {
		return programData!.mealAmount + mealTip()
	}

	//Returns the equivalent meal total, which is the meal total divided by the country exchange rate
	func mealEquivalentTotal() -> Double {
		return mealTotal() / programData!.countryExchangeRate
	}

	//Returns the meal result, which is the meal total divided by the meal people
	func mealResult() -> Double {
		return mealTotal() / Double(programData!.mealPeople)
	}

	//Returns the equivalent meal result, which is the meal result divided by the country exchange rate
	func mealEquivalentResult() -> Double {
		return mealResult() / programData!.countryExchangeRate
	}

	//Returns the equivalent distance amount from the EqualViewController
	func equalEquivalentDistanceAmount() -> Double {
		if programData!.equalDistanceUnit == 0 {
			return programData!.equalDistanceAmount * (25146 / 15625)
		} else {
			return programData!.equalDistanceAmount * (15625 / 25146)
		}
	}

	//Returns the equivalent temperature amount from the EqualViewController
	func equalEquivalentTemperatureAmount() -> Double {
		if programData!.equalTemperatureUnit == 0 {
			return (programData!.equalTemperatureAmount - 32) * (5 / 9)
		} else {
			return (programData!.equalTemperatureAmount * (9 / 5)) + 32
		}
	}

	//Set the scroll view's content size once all of the sub-views have been loaded and resized
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(viewControllers.count), height: scrollView.bounds.height)
	}

	//This code is executed whenever a segue is about to take place
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "MainToHelpSegue" {
			let helpViewController = segue.destination as! HelpViewController
			helpViewController.mainViewController = self
		}
	}

	//Triggers a menu to pop up for changing the origin country
	@IBAction func originCountryButtonPressed() {
		let alertController = UIAlertController(title: "Select your origin country:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

		view.endEditing(true) //Close any open responder beforehand
		for i in stride(from: 0, to: countryNames.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countryNames[i], style: UIAlertActionStyle.default, handler: originCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}

	//Changes the origin country based upon the selected choice
	func originCountryAlertActionHandler(action: UIAlertAction!) {
		for i in stride(from: 0, to: countryNames.count, by: 1) {
			if action.title == countryNames[i] {
				programData!.originCountry = i
				countryExchangeRateRequest()
				break
			}
		}
	}

	//Triggers a menu to pop up for changing the travel country
	@IBAction func travelCountryButtonPressed() {
		let alertController = UIAlertController(title: "Select your travel country:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

		view.endEditing(true) //Close any open responder beforehand
		for i in stride(from: 0, to: countryNames.count, by: 1) {
			alertController.addAction(UIAlertAction(title: countryNames[i], style: UIAlertActionStyle.default, handler: travelCountryAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}

	//Changes the travel country based upon the selected choice
	func travelCountryAlertActionHandler(action: UIAlertAction!) {
		for i in stride(from: 0, to: countryNames.count, by: 1) {
			if action.title == countryNames[i] {
				programData!.travelCountry = i
				countryExchangeRateRequest()
				break
			}
		}
	}

	//Changes the scroll view depending upon what tab button was pressed
	@IBAction func tabButtonPressed(_ sender: Any) {
		view.endEditing(true) //Close any open responder beforehand
		scrollView.contentOffset = CGPoint(x: view.frame.size.width * CGFloat((sender as AnyObject).tag), y: 0)
	}
}
