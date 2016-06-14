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
		tripBuddyViewController!.programData!.miscMeasurement = measurementControl.selectedSegmentIndex
		tripBuddyViewController!.programData!.miscAmount = 0
		tripBuddyViewController!.programData!.miscUnit = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If the amount was changed, save it after changing it to 0
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.miscAmount = parseNumber(amountTextField.text!, minimum: -99999.999, maximum: 99999.999, decimalPlaces: 3)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func toggleButtonPressed(sender: AnyObject) {
		view.endEditing(true) //If the amount was changed, save it before changing the units
		tripBuddyViewController!.programData!.miscUnit = 1 - tripBuddyViewController!.programData!.miscUnit.integerValue
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		tripBuddyViewController!.programData!.miscMeasurement = 0
		tripBuddyViewController!.programData!.miscAmount = 0
		tripBuddyViewController!.programData!.miscUnit = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If the amount was changed, save it after changing it to 0
	}
}