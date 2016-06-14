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
	@IBOutlet weak var convertedUnitControl: UISegmentedControl!
	@IBOutlet weak var convertedAmountLabel: UILabel!
	@IBOutlet weak var convertedRateLabel: UILabel!
	@IBOutlet weak var convertedResultLabel: UILabel!
	@IBOutlet weak var convertedOutcomeLabel: UILabel!
	@IBOutlet weak var convertedDifferenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		rateTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func unitControlChanged(sender: AnyObject) {
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func rateTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func convertedUnitControlChanged(sender: AnyObject) {
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		tripBuddyViewController!.programData!.gasUnit = 1
		tripBuddyViewController!.programData!.gasAmount = 0
		tripBuddyViewController!.programData!.gasRate = 0
		tripBuddyViewController!.programData!.gasOutcome = 0
		tripBuddyViewController!.programData!.gasConvertedUnit = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If any quantity was changed, save it after changing it to its default value
	}
}