//Trip Buddy
//ProgramData.swift
//© 2016 Kaiyode Software

import UIKit
import CoreData

class ProgramData {
	static let countries: [String] = ["Argentina", "Austria", "Bulgaria", "Canada", "Chile",
	                                  "China", "France", "Germany", "India", "Italy", "Japan",
	                                  "Malaysia", "Mexico", "Singapore", "Spain", "Switzerland",
	                                  "United Kingdom", "United States"]

	static let flags: [String] = ["Argentina.png", "Austria.png", "Bulgaria.png", "Canada.png", "Chile.png",
	                              "China.png", "France.png", "Germany.png", "India.png", "Italy.png", "Japan.png",
	                              "Malaysia.png", "Mexico.png", "Singapore.png", "Spain.png", "Switzerland.png",
	                              "United Kingdom.png", "United States.png"]

	static let currencies: [String] = ["Peso", "Euro", "Lev", "Dollar", "Peso",
	                                   "Yuan", "Euro", "Euro", "Rupee", "Euro", "Yen",
	                                   "Ringgit", "Peso", "Dollar", "Euro", "Franc",
	                                   "Pound", "Dollar"]

	static let symbols: [String] = ["$", "€", "лев", "$", "$",
	                                "¥", "€", "€", "₹", "€", "¥",
	                                "R", "$", "$", "€", "C",
	                                "£", "$"]

	static let amounts: [Float] = [9.41, 0.65, 1.75, 1.3336, 704.955,
	                               6.34, 0.65, 0.93, 66.07, 0.94, 122.725,
	                               4.3949, 16.7305, 1.4, 0.92, 0.99,
	                               0.654, 1.5172]

	static func getSaveData() -> SaveData {
		let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		var saveData: [SaveData]

		do {
			saveData = try context.executeFetchRequest(NSFetchRequest(entityName: "SaveData")) as! [SaveData]
		} catch _ as NSError {
			saveData = []
		}
		if saveData.count != 1 {
			for i in (saveData.count - 1).stride(through: 0, by: -1) {
				context.deleteObject(saveData[i] as NSManagedObject)
				saveData.removeAtIndex(i)
			}
			saveData = [NSEntityDescription.insertNewObjectForEntityForName("SaveData", inManagedObjectContext: context) as! SaveData]
			saveData[0].country1 = countries.count - 1
			saveData[0].country2 = countries.count - 2
			do {
				try context.save()
			} catch _ as NSError {}
		}

		return saveData[0]
	}

	static func setSaveData() {
		let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

		do {
			try context.save()
		} catch _ as NSError {}
	}

	static func populateCountryElements(button1: UIButton, imageView1: UIImageView, label1: UILabel, button2: UIButton, imageView2: UIImageView, label2: UILabel, saveData: SaveData) {
		button1.setTitle(countries[saveData.country1.integerValue], forState: UIControlState.Normal)
		//imageView1.image = ... flags[saveData.country1.integerValue] ...
		label1.text = "\(currencies[saveData.country1.integerValue]) " +
			"(\(symbols[saveData.country1.integerValue])) " +
			"\(amounts[saveData.country1.integerValue])"
		button2.setTitle(countries[saveData.country2.integerValue], forState: UIControlState.Normal)
		//imageView2.image = ... flags[saveData.country2.integerValue] ...
		label2.text = "\(currencies[saveData.country2.integerValue]) " +
			"(\(symbols[saveData.country2.integerValue])) " +
			"\(amounts[saveData.country2.integerValue])"
	}

	static func country1ButtonPressed() {
		print("Country 1 Button Pressed")
	}

	static func country2ButtonPressed() {
		print("Country 2 Button Pressed")
	}
}