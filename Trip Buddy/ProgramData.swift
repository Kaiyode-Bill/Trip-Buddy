//Trip Buddy
//ProgramData.swift
//© 2016 Kaiyode Software

import Foundation
import CoreData

class ProgramData: NSManagedObject {
	@NSManaged var country1: NSNumber
	@NSManaged var country2: NSNumber
	//
	@NSManaged var miscMeasurement: NSNumber
	@NSManaged var miscAmount: NSNumber
	@NSManaged var miscUnit: NSNumber
}