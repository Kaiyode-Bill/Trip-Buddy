//Trip Buddy
//MealViewController.swift
//© 2016 Kaiyode Software

import UIKit

class MealViewController: ParentViewController {
	@IBOutlet weak var amountSymbolLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountUnitLabel: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var peopleTextField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeSymbolLabel: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeUnitLabel: UILabel!
	@IBOutlet weak var differenceLabel: UILabel!
	@IBOutlet weak var equivalentUnitLabel: UILabel!
	@IBOutlet weak var equivalentAmountLabel: UILabel!
	@IBOutlet weak var equivalentTipLabel: UILabel!
	@IBOutlet weak var equivalentTotalLabel: UILabel!
	@IBOutlet weak var equivalentResultLabel: UILabel!
	@IBOutlet weak var equivalentOutcomeLabel: UILabel!
	@IBOutlet weak var equivalentDifferenceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		amountTextField.delegate = self
		percentageTextField.delegate = self
		peopleTextField.delegate = self
		outcomeTextField.delegate = self
	}

	@IBAction func amountTextFieldChanged(sender: AnyObject) {
		mainViewController!.programData!.mealAmount = parseNumber(amountTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func percentageTextFieldChanged(sender: AnyObject) {
		mainViewController!.programData!.mealPercentage = parseNumber(percentageTextField.text!, minimum: 0, maximum: 99.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func peopleTextFieldChanged(sender: AnyObject) {
		mainViewController!.programData!.mealPeople = parseNumber(peopleTextField.text!, minimum: 1, maximum: 999, decimalPlaces: 0)
		mainViewController!.saveProgramData()
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
		mainViewController!.programData!.mealOutcome = parseNumber(outcomeTextField.text!, minimum: 0, maximum: 999999.99, decimalPlaces: 2)
		mainViewController!.saveProgramData()
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		view.endEditing(true) //Close any open responder from this view controller beforehand
		mainViewController!.programData!.mealAmount = 0
		mainViewController!.programData!.mealPercentage = 0
		mainViewController!.programData!.mealPeople = 1
		mainViewController!.programData!.mealOutcome = 0
		mainViewController!.saveProgramData()
	}
}