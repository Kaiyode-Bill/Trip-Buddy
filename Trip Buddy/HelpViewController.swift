//Trip Buddy
//HelpViewController.swift
//(c) 2018 Kaiyode Software

import UIKit

class HelpViewController: UIViewController {
	@IBOutlet weak var startupSwitch: UISwitch!
	var mainViewController: MainViewController? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		startupSwitch.isOn = mainViewController!.programData!.showHelpAtStartup
	}

	@IBAction func startupSwitchChanged() {
		mainViewController!.programData!.showHelpAtStartup = startupSwitch.isOn
		mainViewController!.saveProgramData()
	}

	@IBAction func returnButtonPressed() {
		dismiss(animated: true, completion: nil)
	}
}
