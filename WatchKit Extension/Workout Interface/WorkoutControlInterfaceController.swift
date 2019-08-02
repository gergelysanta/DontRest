//
//  WorkoutControlInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 29/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation

class WorkoutControlInterfaceController: WKInterfaceController {

	@IBOutlet weak var endButton: WKInterfaceButton!

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	@IBAction func warnMeSwitchToggled(_ value: Bool) {
		NSLog("Set to: \(value ? "ON" : "OFF")")
	}

	@IBAction func endButtonTapped() {
		// A workout session is running
		Workout.shared.stop()
		// Disable button
		endButton.setEnabled(false)
	}

}
