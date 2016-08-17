//Trip Buddy
//ProgramData.swift
//© 2016 Kaiyode Software

import Foundation
import CoreData

class ProgramData: NSManagedObject {
	@NSManaged var originCountry: NSNumber
	@NSManaged var travelCountry: NSNumber
	@NSManaged var countryExchangeRate: NSNumber
	@NSManaged var showHelpAtStartup: NSNumber
	@NSManaged var exchangeAmount: NSNumber
	@NSManaged var exchangePercentage: NSNumber
	@NSManaged var exchangeOutcome: NSNumber
	@NSManaged var gasUnit: NSNumber
	@NSManaged var gasAmount: NSNumber
	@NSManaged var gasRate: NSNumber
	@NSManaged var gasOutcome: NSNumber
	@NSManaged var gasEquivalentUnit: NSNumber
	@NSManaged var mealAmount: NSNumber
	@NSManaged var mealPercentage: NSNumber
	@NSManaged var mealPeople: NSNumber
	@NSManaged var mealOutcome: NSNumber
	@NSManaged var miscMeasurement: NSNumber
	@NSManaged var miscAmount: NSNumber
	@NSManaged var miscUnit: NSNumber
}