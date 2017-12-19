//Trip Buddy
//EqualViewController.swift
//© 2016 Kaiyode Software

import UIKit

class EqualViewController: ParentViewController {
	@IBOutlet weak var distanceAmountTextField: UITextField!
	@IBOutlet weak var distanceUnitButton: UIButton!
	@IBOutlet weak var equivalentDistanceAmountLabel: UILabel!
	@IBOutlet weak var equivalentDistanceUnitLabel: UILabel!
	@IBOutlet weak var temperatureAmountTextField: UITextField!
	@IBOutlet weak var temperatureUnitButton: UIButton!
	@IBOutlet weak var equivalentTemperatureAmountLabel: UILabel!
	@IBOutlet weak var equivalentTemperatureUnitLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		distanceAmountTextField.delegate = self
		temperatureAmountTextField.delegate = self
	}

	@IBAction func distanceAmountTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.equalDistanceAmount != 0 {
			distanceAmountTextField.selectAll(self)
			distanceAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.equalDistanceAmount.doubleValue)
		} else {
			distanceAmountTextField.text = ""
		}
		distanceAmountTextField.textAlignment = NSTextAlignment.Right
	}

	@IBAction func distanceAmountTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.equalDistanceAmount = parseNumber(distanceAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func distanceUnitButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalDistanceUnit = 1 - mainViewController!.programData!.equalDistanceUnit.integerValue
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureAmountTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.equalTemperatureAmount != 0 {
			temperatureAmountTextField.selectAll(self)
			temperatureAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.equalTemperatureAmount.doubleValue)
		} else {
			temperatureAmountTextField.text = ""
		}
		temperatureAmountTextField.textAlignment = NSTextAlignment.Right
	}

	@IBAction func temperatureAmountTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.equalTemperatureAmount = parseNumber(temperatureAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureUnitButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalTemperatureUnit = 1 - mainViewController!.programData!.equalTemperatureUnit.integerValue
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalDistanceAmount = 0
		mainViewController!.programData!.equalDistanceUnit = 0
		mainViewController!.programData!.equalTemperatureAmount = 0
		mainViewController!.programData!.equalTemperatureUnit = 0
		mainViewController!.saveProgramData()
	}
}
