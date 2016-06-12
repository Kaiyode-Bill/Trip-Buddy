//Trip Buddy
//MiscViewController.swift
//© 2016 Kaiyode Software

import UIKit

class MiscViewController: ParentViewController {
	@IBOutlet weak var measurementControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var unitLabel: UILabel!
	@IBOutlet weak var equivalentLabel: UILabel!
	@IBOutlet weak var toggleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		amountTextField.delegate = self
	}

	@IBAction func measurementChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.miscMeasurement = measurementControl.selectedSegmentIndex
		tripBuddyViewController!.programData!.miscAmount = 0
		tripBuddyViewController!.programData!.miscUnit = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If the amount was changed, save it after changing it to 0
	}

	@IBAction func amountChanged(sender: AnyObject) {
		if Double(amountTextField.text!) != nil {
			tripBuddyViewController!.programData!.miscAmount = truncateDouble(Double(amountTextField.text!)!, decimalPlaces: 3)
		} else {
			tripBuddyViewController!.programData!.miscAmount = 0
		}
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func toggleButtonPressed(sender: AnyObject) {
		view.endEditing(true) //If the amount was changed, save it before changing the units
		tripBuddyViewController!.programData!.miscUnit = 1 - tripBuddyViewController!.programData!.miscUnit.integerValue
		tripBuddyViewController!.saveProgramData()
	}
}