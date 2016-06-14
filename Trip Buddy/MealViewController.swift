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
	}

	@IBAction func percentageTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func peopleTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func outcomeTextFieldChanged(sender: AnyObject) {
	}

	@IBAction func resetButtonPressed(sender: AnyObject) {
		tripBuddyViewController!.programData!.mealAmount = 0
		tripBuddyViewController!.programData!.mealPercentage = 0
		tripBuddyViewController!.programData!.mealPeople = 1
		tripBuddyViewController!.programData!.mealOutcome = 0
		tripBuddyViewController!.saveProgramData()
		view.endEditing(true) //If any quantity was changed, save it after changing it to its default value
	}
}