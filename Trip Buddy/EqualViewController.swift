//Trip Buddy
//EqualViewController.swift
//(c) 2018 Kaiyode Software

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

	@IBAction func distanceAmountTextFieldEntered() {
		if mainViewController!.programData!.equalDistanceAmount != 0 {
			distanceAmountTextField.selectAll(self)
			distanceAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.equalDistanceAmount)
		} else {
			distanceAmountTextField.text = ""
		}
		distanceAmountTextField.textAlignment = NSTextAlignment.right
	}

	@IBAction func distanceAmountTextFieldExited() {
		mainViewController!.programData!.equalDistanceAmount = parseDouble(distanceAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func distanceUnitButtonPressed() {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalDistanceUnit = 1 - mainViewController!.programData!.equalDistanceUnit
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureAmountTextFieldEntered() {
		if mainViewController!.programData!.equalTemperatureAmount != 0 {
			temperatureAmountTextField.selectAll(self)
			temperatureAmountTextField.text = String(format: "%.3f", mainViewController!.programData!.equalTemperatureAmount)
		} else {
			temperatureAmountTextField.text = ""
		}
		temperatureAmountTextField.textAlignment = NSTextAlignment.right
	}

	@IBAction func temperatureAmountTextFieldExited() {
		mainViewController!.programData!.equalTemperatureAmount = parseDouble(temperatureAmountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func temperatureUnitButtonPressed() {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalTemperatureUnit = 1 - mainViewController!.programData!.equalTemperatureUnit
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed() {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.equalDistanceAmount = 0
		mainViewController!.programData!.equalDistanceUnit = 0
		mainViewController!.programData!.equalTemperatureAmount = 0
		mainViewController!.programData!.equalTemperatureUnit = 0
		mainViewController!.saveProgramData()
	}
}
