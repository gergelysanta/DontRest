//
//  WorkoutRowController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 11/04/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit

protocol WorkoutRowDelegate: AnyObject {
	func workoutSettingsTapped(row index: Int)
}

class WorkoutRowController: NSObject {

	@IBOutlet var workoutNameLabel: WKInterfaceLabel!
	@IBOutlet var workoutLastTimeLabel: WKInterfaceLabel!
	
	weak var delegate: WorkoutRowDelegate?
	var rowIndex:Int = 0

	@IBAction func workoutSettingsButtonTapped() {
		delegate?.workoutSettingsTapped(row: rowIndex)
	}

}
