//
//  WorkoutInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 25/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation

class WorkoutInterfaceController: WKInterfaceController {

	@IBOutlet var timer: WKInterfaceTimer!
	@IBOutlet var errorLabel: WKInterfaceLabel!
	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var activeEnergyLabel: WKInterfaceLabel!
	@IBOutlet var totalEnergyLabel: WKInterfaceLabel!

	@IBOutlet var heartRateGroup: WKInterfaceGroup!
	@IBOutlet var activeEnergyGroup: WKInterfaceGroup!
	@IBOutlet var totalEnergyGroup: WKInterfaceGroup!

	@IBOutlet var endButton: WKInterfaceButton!

	private(set) var errorDisplayed = false

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		if !Workout.isAvailable {
			display(error: "Health data not available")
			return
		}

		Workout.shared.delegate = self
		Workout.shared.start(withActivity: Configuration.shared.activity)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	// -------------------------

	private func display(error: String) {
		errorLabel.setText(error)
		errorLabel.setHidden(false)
		timer.setHidden(true)
		heartRateGroup.setHidden(true)
		activeEnergyGroup.setHidden(true)
		totalEnergyGroup.setHidden(true)
		errorDisplayed = true
	}

	private func exitWorkoutInterface() {
		WKInterfaceController.reloadRootControllers(withNames: ["MainInterface","SetupActivityInterface","SetupTimesInterface"], contexts: nil)
	}

	@IBAction func endButtonTapped() {
		if errorDisplayed {
			// We have an error displayed, pushing 'End' means - go back to main interface
			exitWorkoutInterface()
		} else {
			// A workout session is running
			Workout.shared.stop()
			// Disable "End" button to prevent multiple taps
			endButton.setEnabled(false)
		}
	}
	
}

extension WorkoutInterfaceController: WorkoutDelegate {

	func workoutDidStart(_ workout: Workout) {
		timer.start()
	}

	func workoutDidStop(_ workout: Workout) {
		timer.stop()
		exitWorkoutInterface()
	}

	func workout(_ workout: Workout, valueChanged: Workout.ValueType) {
		switch valueChanged {
		case .lastHeartRate:
			heartRateLabel.setText(String(format: "%.0f", workout.lastHeartRate))
		case .activeEnergyBurned:
			activeEnergyLabel.setText(String(format: "%.0f", workout.activeEnergyBurned))
		case .totalEnergyBurned:
			totalEnergyLabel.setText(String(format: "%.0f", workout.totalEnergyBurned))
		}
	}

	func workout(_ workout: Workout, errorReceived error: String) {
		display(error: error)
	}

}
