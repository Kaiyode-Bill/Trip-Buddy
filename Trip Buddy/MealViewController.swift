//Trip Buddy
//MealViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class MealViewController: ParentViewController {
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var equivalentAmountLabel: UILabel!
	@IBOutlet weak var percentagePrefixLabel: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var equivalentTipLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var equivalentTotalLabel: UILabel!
	@IBOutlet weak var peoplePrefixLabel: UILabel!
	@IBOutlet weak var peopleTextField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var equivalentResultLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		percentageTextField.delegate = self
		peopleTextField.delegate = self
	}

	@IBAction func amountTextFieldEntered() {
		if mainViewController!.programData!.mealAmount != 0 {
			amountTextField.selectAll(self)
			amountTextField.text = String(format: "%.2f", mainViewController!.programData!.mealAmount.doubleValue)
		} else {
			amountTextField.text = ""
		}
		amountTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func amountTextFieldExited() {
		mainViewController!.programData!.mealAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		if mainViewController!.programData!.mealAmount == 0 {
			mainViewController!.programData!.mealPercentage = 0
			mainViewController!.programData!.mealPeople = 1
		}
		mainViewController!.saveProgramData()
	}

	@IBAction func percentageTextFieldEntered() {
		if mainViewController!.programData!.mealPercentage != 0 {
			percentageTextField.selectAll(self)
			percentageTextField.text = "\(mainViewController!.programData!.mealPercentage.integerValue)"
		} else {
			percentageTextField.text = ""
		}
		percentageTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func percentageTextFieldExited() {
		mainViewController!.programData!.mealPercentage = parseNumber(percentageTextField.text!, minimum: 0, maximum: 30, decimalPlaces: 0)
		mainViewController!.saveProgramData()
	}

	@IBAction func peopleTextFieldEntered() {
		if mainViewController!.programData!.mealPeople != 1 {
			peopleTextField.selectAll(self)
			peopleTextField.text = "\(mainViewController!.programData!.mealPeople.integerValue)"
		} else {
			peopleTextField.text = ""
		}
		peopleTextField.textAlignment = NSTextAlignment.center
	}

	@IBAction func peopleTextFieldExited() {
		mainViewController!.programData!.mealPeople = parseNumber(peopleTextField.text!, minimum: 1, maximum: 30, decimalPlaces: 0)
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed() {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.mealAmount = 0
		mainViewController!.programData!.mealPercentage = 0
		mainViewController!.programData!.mealPeople = 1
		mainViewController!.saveProgramData()
	}
}
