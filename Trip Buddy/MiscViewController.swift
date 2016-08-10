//Trip Buddy
//MiscViewController.swift
//© 2016 Kaiyode Software

import UIKit

class MiscViewController: ParentViewController {
	@IBOutlet weak var measurementControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountUnitLabel: UILabel!
	@IBOutlet weak var equivalentLabel: UILabel!
	@IBOutlet weak var toggleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		amountTextField.delegate = self
	}

	@IBAction func measurementControlChanged(sender: AnyObject) {
		let changedValue = measurementControl.selectedSegmentIndex

		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscMeasurement = changedValue
		mainViewController!.programData!.miscAmount = 0
		mainViewController!.programData!.miscUnit = 0
		mainViewController!.saveProgramData()
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
		mainViewController!.programData!.miscAmount = parseNumber(amountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		mainViewController!.saveProgramData()
	}

	@IBAction func toggleButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscUnit = 1 - mainViewController!.programData!.miscUnit.integerValue
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.miscMeasurement = 0
		mainViewController!.programData!.miscAmount = 0
		mainViewController!.programData!.miscUnit = 0
		mainViewController!.saveProgramData()
	}
}