//
//  MainInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 24/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class MainInterfaceController: WKInterfaceController {

	@IBOutlet weak var workoutsTable: WKInterfaceTable!

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		// Populate the workouts table
		let activities = Configuration.shared.activities
		workoutsTable.setNumberOfRows(activities.count, withRowType: "WorkoutRow")

		for index in 0 ..< activities.count {
			guard let rowController = workoutsTable.rowController(at: index) as? WorkoutRowController else { continue }

			rowController.workoutNameLabel.setText("\(activities[index].name)")
			rowController.rowIndex = index
			rowController.delegate = self
		}
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		guard
			table == workoutsTable,
			rowIndex < Configuration.shared.activities.count
		else { return }

		// Fetch selected activity
		let activity = Configuration.shared.activities[rowIndex]
		let configuration = activity.configuration
		// Set it as new selected activity
		Configuration.shared.activity = activity
		// And start workout
		WKInterfaceController.reloadRootControllers(withNames: ["WorkoutMainController","WorkoutMusicController","WorkoutWarningsController"],
													contexts: [configuration, configuration, configuration])
	}

}

extension MainInterfaceController: WorkoutRowDelegate {

	func workoutSettingsTapped(row index: Int) {
		guard index >= 0, index < Configuration.shared.activities.count else { return }

		// Get activity for triggered row
		let activity = Configuration.shared.activities[index].configuration

		// Detect controllers for activity type
		var controllerNames:[String] = []
		if activity is SetsWorkoutConfiguration {
			controllerNames = ["WorkoutSetsConfiguration", "WorkoutTimesConfiguration"]
		}

		// Present controllers
		if !controllerNames.isEmpty {
			presentController(withNames: controllerNames, contexts: [activity, activity])
		}
	}

}
