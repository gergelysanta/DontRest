//
//  BaseWorkoutConfiguration.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 12/04/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation
import HealthKit

class BaseWorkoutConfiguration {

	/// Workout type
	var type:HKWorkoutActivityType

	/// Length of last workout
	var length:UInt = 0

	init(_ type: HKWorkoutActivityType) {
		self.type = type
	}

}
