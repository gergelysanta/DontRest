//
//  SetsWorkoutConfiguration.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 12/04/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation

class SetsWorkoutConfiguration: BaseWorkoutConfiguration {

		// Sets count
		var sets = RangedInt(value: 3)

		// Length of allowed rest between sets
		var restBetweenSets = RangedTime(seconds: 60)		// 1 minute

		// Length of allowed rest between exercises sets
		var restBetweenExercises = RangedTime(seconds: 180)	// 3 minutes

}
