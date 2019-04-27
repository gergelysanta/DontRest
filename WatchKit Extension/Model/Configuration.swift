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

	/// All known activities
	typealias Activity = (name: String, configuration: BaseWorkoutConfiguration)
	private(set) var activities:[Activity] = [
		("Functional",	SetsWorkoutConfiguration(.functionalStrengthTraining)),
		("Strength",	SetsWorkoutConfiguration(.traditionalStrengthTraining)),
		("Elliptical",	SetsWorkoutConfiguration(.elliptical)),
		("Running",		SetsWorkoutConfiguration(.running)),
		("Other",		SetsWorkoutConfiguration(.other))
	]

	/// Selected activity
	var activity:Activity {
		didSet {
			// Get index of newly selected activity
			guard let fromIndex = activities.firstIndex(where: {$0.name == activity.name }) else { return }
			// Remove it from array of activities...
			let entry = activities.remove(at: fromIndex)
			// ..and add back to the beginning
			activities.insert(entry, at: 0)
		}
	}

	private init() {
		activity = activities.first!
	}

}
