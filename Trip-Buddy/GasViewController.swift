//Trip Buddy
//GasViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class GasViewController: ParentViewController {
	@IBOutlet weak var unitButton: UIButton!
	@IBOutlet weak var equivalentUnitButton: UIButton!
	@IBOutlet weak var ratePrefixLabel: UILabel!
	@IBOutlet weak var rateTextField: UITextField!
	@IBOutlet weak var equivalentRateLabel: UILabel!
	@IBOutlet weak var amountPrefixLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomePrefixLabel: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var differenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		rateTextField.delegate = self
		amountTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func unitButtonPressed() {
		let alertController = UIAlertController(title: "Select the current gas unit:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

		view.endEditing(true) //Close any open responder from this view controller beforehand
		for i in stride(from: 0, to: mainViewController!.gasUnits.count, by: 1) {
			alertController.addAction(UIAlertAction(title: "\(mainViewController!.gasUnits[i])s", style: UIAlertActionStyle.default, handler: unitAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
		mainViewController!.present(alertController, animated: true, completion: nil)
	}

    func unitAlertActionHandler(action: UIAlertAction!) {
		for i in stride(from: 0, to: mainViewController!.gasUnits.count, by: 1) {
			if action.title == "\(mainViewController!.gasUnits[i])s" {
				mainViewController!.programData!.gasUnit = i
				mainViewController!.saveProgramData()
				break
			}
		}
	}

	@IBAction func equivalentUnitButtonPressed() {
		let alertController = UIAlertController(title: "Select your native gas unit:", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)

		view.endEditing(true) //Close any open responder from this view controller beforehand
		for i in stride(from: 0, to: mainViewController!.gasUnits.count, by: 1) {
			alertController.addAction(UIAlertAction(title: "\(mainViewController!.gasUnits[i])s", style: UIAlertActionStyle.default, handler: equivalentUnitAlertActionHandler))
		}
		alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
		mainViewController!.present(alertController, animated: true, completion: nil)
	}

    func equivalentUnitAlertActionHandler(action: UIAlertAction!) {
		for i in stride(from: 0, to: mainViewController!.gasUnits.count, by: 1) {
			if action.title == "\(mainViewController!.gasUnits[i])s" {
				mainViewController!.programData!.gasEquivalentUnit = i
				mainViewController!.saveProgramData()
				break
			}
		}
	}

	@IBAction func rateTextFieldEntered() {
		if mainViewController!.programData!.gasRate != 0 {
			rateTextField.selectAll(self)
			rateTextField.text = String(format: "%.2f", mainViewController!.programData!.gasRate)
		} else {
			rateTextField.text = ""
		}
		rateTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func rateTextFieldExited() {
		mainViewController!.programData!.gasRate = parseNumber(rateTextField.text!, minimum: 0, maximum: 999.99, decimalPlaces: 2)
		if mainViewController!.programData!.gasRate == 0 {
			mainViewController!.programData!.gasAmount = 0
			mainViewController!.programData!.gasOutcome = 0
		}
		mainViewController!.saveProgramData()
	}

	@IBAction func amountTextFieldEntered() {
		if mainViewController!.programData!.gasAmount != 0 {
			amountTextField.selectAll(self)
			amountTextField.text = String(format: "%.2f", mainViewController!.programData!.gasAmount)
		} else {
			amountTextField.text = ""
		}
		amountTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func amountTextFieldExited() {
		mainViewController!.programData!.gasAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999.99, decimalPlaces: 2)
		if mainViewController!.programData!.gasAmount == 0 {
			mainViewController!.programData!.gasOutcome = 0
		}
		mainViewController!.saveProgramData()
	}

	@IBAction func outcomeTextFieldEntered() {
		if mainViewController!.programData!.gasOutcome != 0 {
			outcomeTextField.selectAll(self)
			outcomeTextField.text = String(format: "%.2f", mainViewController!.programData!.gasOutcome)
		} else {
			outcomeTextField.text = ""
		}
		outcomeTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func outcomeTextFieldExited() {
		mainViewController!.programData!.gasOutcome = parseNumber(outcomeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed() {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.gasUnit = 1
		mainViewController!.programData!.gasEquivalentUnit = 0
		mainViewController!.programData!.gasRate = 0
		mainViewController!.programData!.gasAmount = 0
		mainViewController!.programData!.gasOutcome = 0
		mainViewController!.saveProgramData()
	}
}
