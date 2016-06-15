//Trip Buddy
//HelpViewController.swift
//© 2016 Kaiyode Software

import UIKit

class HelpViewController: UIViewController {
	@IBOutlet weak var startupSwitch: UISwitch!
	var tripBuddyViewController: TripBuddyViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		startupSwitch.on = tripBuddyViewController!.programData!.showHelpAtStartup.boolValue
	}

	@IBAction func startupSwitchChanged(sender: AnyObject) {
		tripBuddyViewController!.programData!.showHelpAtStartup = startupSwitch.on
		tripBuddyViewController!.saveProgramData()
	}

	@IBAction func returnButtonPressed(sender: AnyObject) {
		navigationController!.popViewControllerAnimated(true)
	}
}