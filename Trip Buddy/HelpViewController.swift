//Trip Buddy
//HelpViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class HelpViewController: UIViewController {
	@IBOutlet weak var startupSwitch: UISwitch!
	var mainViewController: MainViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		startupSwitch.on = mainViewController!.programData!.showHelpAtStartup.boolValue
	}

	@IBAction func startupSwitchChanged() {
		mainViewController!.programData!.showHelpAtStartup = startupSwitch.on
		mainViewController!.saveProgramData()
	}

	@IBAction func returnButtonPressed() {
		dismiss(animated: true, completion: nil)
	}
}
