//Trip Buddy
//ExchangeViewController.swift
//© 2016 Kaiyode Software

import UIKit

class ExchangeViewController: ParentViewController {
	@IBOutlet weak var conversionLabel: UILabel!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var amountLabel1: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountLabel2: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var feeLabel: UILabel!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeLabel1: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeLabel2: UILabel!
	@IBOutlet weak var differenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		percentageTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func percentageTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func helpButtonPressed(sender: AnyObject) {
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		tripBuddyViewController!.programData!.exchangeAmount = 0
		tripBuddyViewController!.programData!.exchangePercentage = 0
		tripBuddyViewController!.programData!.exchangeOutcome = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If any quantity was changed, save it after changing it to its default value
	}
}