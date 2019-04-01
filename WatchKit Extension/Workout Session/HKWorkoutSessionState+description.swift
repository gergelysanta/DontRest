//
//  HKWorkoutSessionState+description.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 29/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import HealthKit

extension HKWorkoutSessionState {

	var description:String {
		switch self {
		case .notStarted:
			return "notStarted"
		case .paused:
			return "paused"
		case .prepared:
			return "prepared"
		case .running:
			return "running"
		case .stopped:
			return "stopped"
		case .ended:
			return "ended"
		@unknown default:
			return "UNKNOWN[\(rawValue)]"
		}
	}

}
