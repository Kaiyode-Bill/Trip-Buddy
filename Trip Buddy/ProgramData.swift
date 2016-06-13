//Trip Buddy
//ProgramData.swift
//© 2016 Kaiyode Software

import Foundation
import CoreData

class ProgramData: NSManagedObject {
	@NSManaged var originCountry: NSNumber
	@NSManaged var travelCountry: NSNumber
	//
	@NSManaged var miscMeasurement: NSNumber
	@NSManaged var miscAmount: NSNumber
	@NSManaged var miscUnit: NSNumber
}