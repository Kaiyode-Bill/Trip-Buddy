//Trip Buddy
//GasViewController.swift
//© 2016 Kaiyode Software

import UIKit

class GasViewController: ParentViewController {
	@IBOutlet weak var unitControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountUnitLabel: UILabel!
	@IBOutlet weak var rateSymbolLabel: UILabel!
	@IBOutlet weak var rateTextField: UITextField!
	@IBOutlet weak var rateUnitLabel: UILabel!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeSymbolLabel: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeUnitLabel: UILabel!
	@IBOutlet weak var differenceLabel: UILabel!
	@IBOutlet weak var equivalentUnitControl: UISegmentedControl!
	@IBOutlet weak var exchangeRateLabel: UILabel!
	@IBOutlet weak var equivalentAmountLabel: UILabel!
	@IBOutlet weak var equivalentRateLabel: UILabel!
	@IBOutlet weak var equivalentResultLabel: UILabel!
	@IBOutlet weak var equivalentOutcomeLabel: UILabel!
	@IBOutlet weak var equivalentDifferenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		rateTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func unitControlChanged(sender: AnyObject) {
		let changedValue = unitControl.selectedSegmentIndex

		view.endEditing(true) //Close any open responder from this view controller beforehand
		tripBuddyViewController!.programData!.gasUnit = changedValue
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.gasAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func rateTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.gasRate = parseNumber(rateTextField.text!, minimum: 0, maximum: 999.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.gasOutcome = parseNumber(outcomeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func equivalentUnitControlChanged(sender: AnyObject) {
		let changedValue = equivalentUnitControl.selectedSegmentIndex

		view.endEditing(true) //Close any open responder from this view controller beforehand
		tripBuddyViewController!.programData!.gasEquivalentUnit = changedValue
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		tripBuddyViewController!.programData!.gasUnit = 1
		tripBuddyViewController!.programData!.gasAmount = 0
		tripBuddyViewController!.programData!.gasRate = 0
		tripBuddyViewController!.programData!.gasOutcome = 0
		tripBuddyViewController!.programData!.gasEquivalentUnit = 0
		tripBuddyViewController!.saveProgramData()
	}
}