//Trip Buddy
//GasViewController.swift
//© 2016 Kaiyode Software

import UIKit

class GasViewController: UIViewController {
	@IBOutlet weak var country1Button: UIButton!
	@IBOutlet weak var country1ImageView: UIImageView!
	@IBOutlet weak var country1Label: UILabel!
	@IBOutlet weak var country2Button: UIButton!
	@IBOutlet weak var country2ImageView: UIImageView!
	@IBOutlet weak var country2Label: UILabel!
	var saveData: SaveData? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		saveData = ProgramData.getSaveData()
		ProgramData.populateCountryElements(country1Button, imageView1: country1ImageView, label1: country1Label, button2: country2Button, imageView2: country2ImageView, label2: country2Label, saveData: saveData!)
	}

	@IBAction func country1ButtonPressed(sender: AnyObject) {
		ProgramData.country1ButtonPressed()
	}

	@IBAction func country2ButtonPressed(sender: AnyObject) {
		ProgramData.country2ButtonPressed()
	}
}