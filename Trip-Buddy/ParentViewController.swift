//Trip Buddy
//ParentViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class ParentViewController: UIViewController, UITextFieldDelegate {
	var mainViewController: MainViewController? = nil

	//Dismisses the keyboard upon pressing Done, or typing the Enter key
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return false
	}

	//Dismisses the keyboard upon pressing outside of it
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
		super.touchesBegan(touches, with: event)
	}

	//Parses a number from a string to a legitimate value, as defined by the minimum, maximum and decimal places
	func parseNumber(text: String, minimum: Double, maximum: Double, decimalPlaces: Int) -> Double {
		var result = 0.0

		if Double(text) != nil {
			result = Double(text)!
		}
		if result > maximum {
			result = maximum
		} else if result < minimum {
			result = minimum
		}

		return Double(String(format: "%.\(decimalPlaces)f", result))!
	}
}
