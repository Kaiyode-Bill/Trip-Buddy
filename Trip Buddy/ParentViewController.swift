//Trip Buddy
//ParentViewController.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class ParentViewController: UIViewController, UITextFieldDelegate {
	var tripBuddyViewController: TripBuddyViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	//Dismisses the responder when blank area is touched
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent!) {
		resignResponder()
		super.touchesBegan(touches, withEvent: event)
	}

	//Dismisses the responder when the enter key is pressed
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		resignResponder()
		return false
	}

	//Resigns the responder - children should control what happens to their text field values
	func resignResponder() {
		view.endEditing(true)
	}

	//Truncates a double value down to the specified decimal places at most
	func truncateDouble(number: Double, decimalPlaces: Int) -> Double {
		return Double(String(format: "%.\(decimalPlaces)f", number))!
	}
}