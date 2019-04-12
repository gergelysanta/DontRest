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
	var activity:Activity

	private init() {
		activity = activities.first!
	}

}
