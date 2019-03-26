//
//  Configuration.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 25/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation
import HealthKit

class Configuration {

	static let shared = Configuration()

	// Sets count
	var sets = RangedInt(value: 3)

	// Length of allowed rest between sets
	var restBetweenSets = RangedTime(seconds: 60)		// 1 minute

	// Length of allowed rest between exercises sets
	var restBetweenExercises = RangedTime(seconds: 180)	// 3 minutes

	// Available workouts for this application
	typealias Activity = (name: String, type: HKWorkoutActivityType)
	let availableActivities:[Activity] = [
		(name: "Functional", type: .functionalStrengthTraining),
		(name: "Strength", type: .traditionalStrengthTraining),
		(name: "Other", type: .other)
	]
	var activity:HKWorkoutActivityType = .other

	var activityIndex:Int {
		get {
			for (index, listedActivity) in availableActivities.enumerated() {
				if listedActivity.type == activity {
					return index
				}
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableActivities.count) {
				activity = availableActivities[newValue].type
				#if DEBUG
				NSLog("Activity: \(availableActivities[newValue].name)")
				#endif
			}
		}
	}

}
