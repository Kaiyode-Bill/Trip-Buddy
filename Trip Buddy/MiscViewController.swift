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

	override func resignResponder() {
		if amountTextField.isFirstResponder() {
			super.resignResponder()
			if Double(amountTextField.text!) != nil {
				tripBuddyViewController!.programData!.miscAmount = truncateDouble(Double(amountTextField.text!)!, decimalPlaces: 3)
			} else {
				tripBuddyViewController!.programData!.miscAmount = 0
			}
			tripBuddyViewController!.saveProgramData()
		}
	}

	@IBAction func measurementChanged(sender: AnyObject) {
		resignResponder()
		tripBuddyViewController!.programData!.miscMeasurement = measurementControl.selectedSegmentIndex
		tripBuddyViewController!.programData!.miscAmount = 0
		tripBuddyViewController!.programData!.miscUnit = 0
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func toggleButtonPressed(sender: AnyObject) {
		resignResponder()
		tripBuddyViewController!.programData!.miscUnit = 1 - tripBuddyViewController!.programData!.miscUnit.integerValue
		tripBuddyViewController!.saveProgramData()
	}
}