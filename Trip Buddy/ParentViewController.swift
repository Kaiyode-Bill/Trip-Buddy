//Trip Buddy
//ParentViewController.swift
//© 2016 Kaiyode Software

import UIKit

class ParentViewController: UIViewController, UITextFieldDelegate {
	var tripBuddyViewController: TripBuddyViewController? = nil

	//Dismisses the responder when blank area is touched
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent!) {
		view.endEditing(true)
		super.touchesBegan(touches, withEvent: event)
	}

	//Dismisses the responder when the enter key is pressed
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		view.endEditing(true)
		return false
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