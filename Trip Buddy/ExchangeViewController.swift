//Trip Buddy
//ExchangeViewController.swift
//© 2016 Kaiyode Software

import UIKit

class ExchangeViewController: ParentViewController {
	@IBOutlet weak var unitsLabel: UILabel!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var amountSymbolLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountUnitLabel: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var feeLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeSymbolLabel: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeUnitLabel: UILabel!
	@IBOutlet weak var differenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		percentageTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.exchangeAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func percentageTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.exchangePercentage = parseNumber(percentageTextField.text!, minimum: 0, maximum: 99.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.exchangeOutcome = parseNumber(outcomeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func helpButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		tripBuddyViewController!.performSegueWithIdentifier("TripBuddyToHelpSegue", sender: self)
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		tripBuddyViewController!.programData!.exchangeAmount = 0
		tripBuddyViewController!.programData!.exchangePercentage = 0
		tripBuddyViewController!.programData!.exchangeOutcome = 0
		tripBuddyViewController!.saveProgramData()
	}
}