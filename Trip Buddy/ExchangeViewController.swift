//Trip Buddy
//ExchangeViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class ExchangeViewController: ParentViewController {
	@IBOutlet weak var unitsLabel: UILabel!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var percentagePrefixLabel: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var feePrefixLabel: UILabel!
	@IBOutlet weak var feeTextField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomePrefixLabel: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var differenceLabel: UILabel!
	@IBOutlet weak var helpButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		percentageTextField.delegate = self
		feeTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func amountTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.exchangeAmount != 0 {
			amountTextField.selectAll(self)
			amountTextField.text = String(format: "%.2f", mainViewController!.programData!.exchangeAmount.doubleValue)
		} else {
			amountTextField.text = ""
		}
		amountTextField.textAlignment = NSTextAlignment.Center
	}

	@IBAction func amountTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.exchangeAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		if mainViewController!.programData!.exchangeAmount == 0 {
			mainViewController!.programData!.exchangePercentage = 0
			mainViewController!.programData!.exchangeFee = 0
			mainViewController!.programData!.exchangeOutcome = 0
		}
		mainViewController!.saveProgramData()
	}

	@IBAction func percentageTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.exchangePercentage != 0 {
			percentageTextField.selectAll(self)
			percentageTextField.text = "\(mainViewController!.programData!.exchangePercentage.integerValue)"
		} else {
			percentageTextField.text = ""
		}
		percentageTextField.textAlignment = NSTextAlignment.Center
	}

	@IBAction func percentageTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.exchangePercentage = parseNumber(percentageTextField.text!, minimum: 0, maximum: 30, decimalPlaces: 0)
		mainViewController!.programData!.exchangeFee = mainViewController!.programData!.exchangeAmount.doubleValue * (mainViewController!.programData!.exchangePercentage.doubleValue / 100)
		mainViewController!.saveProgramData()
	}

	@IBAction func feeTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.exchangeFee != 0 {
			feeTextField.selectAll(self)
			feeTextField.text = String(format: "%.2f", mainViewController!.programData!.exchangeFee.doubleValue)
		} else {
			feeTextField.text = ""
		}
		feeTextField.textAlignment = NSTextAlignment.Center
	}

	@IBAction func feeTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.exchangeFee = parseNumber(feeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func outcomeTextFieldEntered(sender: AnyObject) {
		if mainViewController!.programData!.exchangeOutcome != 0 {
			outcomeTextField.selectAll(self)
			outcomeTextField.text = String(format: "%.2f", mainViewController!.programData!.exchangeOutcome.doubleValue)
		} else {
			outcomeTextField.text = ""
		}
		outcomeTextField.textAlignment = NSTextAlignment.Center
	}

	@IBAction func outcomeTextFieldExited(sender: AnyObject) {
		mainViewController!.programData!.exchangeOutcome = parseNumber(outcomeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func helpButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.performSegueWithIdentifier("MainToHelpSegue", sender: self)
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.exchangeAmount = 0
		mainViewController!.programData!.exchangePercentage = 0
		mainViewController!.programData!.exchangeFee = 0
		mainViewController!.programData!.exchangeOutcome = 0
		mainViewController!.saveProgramData()
	}
}
