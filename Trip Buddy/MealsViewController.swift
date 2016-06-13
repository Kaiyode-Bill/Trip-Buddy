//Trip Buddy
//MealsViewController.swift
//© 2016 Kaiyode Software

import UIKit

class MealsViewController: ParentViewController {
	@IBOutlet weak var amountLabel1: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountLabel2: UILabel!
	@IBOutlet weak var percentageTextField: UITextField!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var peopleTextField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeLabel1: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeLabel2: UILabel!
	@IBOutlet weak var differenceLabel: UILabel!
	@IBOutlet weak var convertedUnitLabel: UILabel!
	@IBOutlet weak var convertedAmountLabel: UILabel!
	@IBOutlet weak var convertedTipLabel: UILabel!
	@IBOutlet weak var convertedTotalLabel: UILabel!
	@IBOutlet weak var convertedResultLabel: UILabel!
	@IBOutlet weak var convertedOutcomeLabel: UILabel!
	@IBOutlet weak var convertedDifferenceLabel: UILabel!

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
	}
}