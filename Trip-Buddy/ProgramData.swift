//Trip Buddy
//ProgramData.swift
//(c) 2018 Kaiyode Software

import Foundation
import CoreData

class ProgramData: NSManagedObject {
	@NSManaged var originCountry: Int
	@NSManaged var travelCountry: Int
	@NSManaged var countryExchangeRate: Double
	@NSManaged var countryExchangeDate: String
	@NSManaged var showHelpAtStartup: Bool
	@NSManaged var exchangeAmount: Double
	@NSManaged var exchangePercentage: Int
	@NSManaged var exchangeFee: Double
	@NSManaged var exchangeOutcome: Double
	@NSManaged var gasUnit: Int
	@NSManaged var gasEquivalentUnit: Int
	@NSManaged var gasRate: Double
	@NSManaged var gasAmount: Double
	@NSManaged var gasOutcome: Double
	@NSManaged var mealAmount: Double
	@NSManaged var mealPercentage: Int
	@NSManaged var mealPeople: Int
	@NSManaged var equalDistanceAmount: Double
	@NSManaged var equalDistanceUnit: Int
	@NSManaged var equalTemperatureAmount: Double
	@NSManaged var equalTemperatureUnit: Int
}
