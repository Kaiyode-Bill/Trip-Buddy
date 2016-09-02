//Trip Buddy
//MiscViewController.swift
//© 2016 Kaiyode Software

import UIKit

class MiscViewController: ParentViewController {
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
		if mainViewController!.programData!.miscDistanceAmount != 0 {
			distanceAmountTextField.selectAll(self)
			distanceAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.miscDistanceAmount.doubleValue)
		} else {
			distanceAmountTextField.text = ""
		}
		distanceAmountTextField.textAlignment = NSTextAlignment.Right
	}

	@IBAction func distanceAmountTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.miscDistanceAmount = parseNumber(distanceAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func distanceUnitButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscDistanceUnit = 1 - mainViewController!.programData!.miscDistanceUnit.integerValue
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureAmountTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.miscTemperatureAmount != 0 {
			temperatureAmountTextField.selectAll(self)
			temperatureAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.miscTemperatureAmount.doubleValue)
		} else {
			temperatureAmountTextField.text = ""
		}
		temperatureAmountTextField.textAlignment = NSTextAlignment.Right
	}

	@IBAction func temperatureAmountTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.miscTemperatureAmount = parseNumber(temperatureAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscTemperatureUnit = 1 - mainViewController!.programData!.miscTemperatureUnit.integerValue
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscDistanceAmount = 0
		mainViewController!.programData!.miscDistanceUnit = 0
		mainViewController!.programData!.miscTemperatureAmount = 0
		mainViewController!.programData!.miscTemperatureUnit = 0
		mainViewController!.saveProgramData()
	}
}