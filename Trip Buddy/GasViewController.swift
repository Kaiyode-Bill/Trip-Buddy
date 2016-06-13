//Trip Buddy
//GasViewController.swift
//© 2016 Kaiyode Software

import UIKit

class GasViewController: ParentViewController {
	@IBOutlet weak var unitControl: UISegmentedControl!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountLabel2: UILabel!
	@IBOutlet weak var rateLabel1: UILabel!
	@IBOutlet weak var rateTextField: UITextField!
	@IBOutlet weak var rateLabel2: UILabel!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var outcomeLabel1: UILabel!
	@IBOutlet weak var outcomeTextField: UITextField!
	@IBOutlet weak var outcomeLabel2: UILabel!
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
	}
}