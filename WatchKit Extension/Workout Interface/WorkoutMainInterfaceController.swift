//
//  WorkoutMainInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 25/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation

class WorkoutMainInterfaceController: WKInterfaceController {

	@IBOutlet var timer: WKInterfaceTimer!
	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var activeEnergyLabel: WKInterfaceLabel!
	@IBOutlet var totalEnergyLabel: WKInterfaceLabel!

	override func didAppear() {
		super.didAppear()

		if !Workout.isAvailable {
			display(error: "Health data not available")
			return
		}

		Workout.shared.delegate = self
		Workout.shared.start(withActivity: Configuration.shared.activity.configuration.type)
	}

	// -------------------------

	private func display(error: String) {
		let alert = WKAlertAction(title: "OK", style: .default) {
			// We have an error displayed, pushing 'End' means - go back to main interface
			self.exitWorkoutInterface()
		}
		presentAlert(withTitle: "ERROR:",
					 message: error,
					 preferredStyle: .alert,
					 actions: [alert])
	}

	private func exitWorkoutInterface() {
		WKInterfaceController.reloadRootControllers(withNames: ["MainInterface"], contexts: nil)
	}
	
}

extension WorkoutMainInterfaceController: WorkoutDelegate {

	func workoutDidStart(_ workout: Workout) {
		timer.start()
	}

	func workoutDidStop(_ workout: Workout, seconds: TimeInterval) {
		timer.stop()
		// Remember activity length
		// As active workout was moved to the beginning of the array when started,
		// we may rely on that (first one is the actually stopped one)
		Configuration.shared.activities.first?.configuration.length = UInt(seconds)
		// Exit workout interface
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
