//
//  SetupTimesInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 26/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation


class SetupTimesInterfaceController: WKInterfaceController {

	@IBOutlet var restSetsTimeMinutesPicker: WKInterfacePicker!
	@IBOutlet var restSetsTimeSecondsPicker: WKInterfacePicker!
	@IBOutlet var restExercisesMinutePicker: WKInterfacePicker!
	@IBOutlet var restExercisesSecondsPicker: WKInterfacePicker!

	private var minutesValue:Int = 0
	private var secondsValue:Int = 0

	private var activityConfiguration:SetsWorkoutConfiguration! {
		didSet {
			minutesValue = activityConfiguration.restBetweenSets.rawValue / 60
			secondsValue = activityConfiguration.restBetweenSets.rawValue % 60
		}
	}

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		if let configuration = context as? SetsWorkoutConfiguration {
			activityConfiguration = configuration
		} else {
			dismiss()
			return
		}

		// Fill up rest minutes picker with values
		var minutesItems = [WKPickerItem]()
		for minute in activityConfiguration.restBetweenSets.availableMinutes {
			let item = WKPickerItem()
			item.title = "\(minute)"
			minutesItems.append(item)
		}
		restSetsTimeMinutesPicker.setItems(minutesItems)
		restSetsTimeMinutesPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.minutesIndex)
		restExercisesMinutePicker.setItems(minutesItems)
		restExercisesMinutePicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.minutesIndex)

		// Fill up rest seconds picker with values
		var secondsItems = [WKPickerItem]()
		for seconds in activityConfiguration.restBetweenSets.availableSeconds {
			let item = WKPickerItem()
			item.title = String(format: "%02d", seconds)
			secondsItems.append(item)
		}
		restSetsTimeSecondsPicker.setItems(secondsItems)
		restSetsTimeSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.secondsIndex)
		restExercisesSecondsPicker.setItems(secondsItems)
		restExercisesSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.secondsIndex)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	// MARK: - Rest between sets time counter

	@IBAction func increaseSetsRestTimeButtonTapped() {
		activityConfiguration.restBetweenSets.rawValue += 5
		let storedSeconds = activityConfiguration.restBetweenSets.rawValue
		restSetsTimeMinutesPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.minutesIndex)
		activityConfiguration.restBetweenSets.rawValue = storedSeconds
		restSetsTimeSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.secondsIndex)
	}

	@IBAction func decreaseSetsRestTimeButtonTapped() {
		activityConfiguration.restBetweenSets.rawValue -= 5
		let storedSeconds = activityConfiguration.restBetweenSets.rawValue
		restSetsTimeMinutesPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.minutesIndex)
		activityConfiguration.restBetweenSets.rawValue = storedSeconds
		restSetsTimeSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenSets.secondsIndex)
	}

	@IBAction func restSetsMinutesValueChanged(_ value: Int) {
		activityConfiguration.restBetweenSets.minutesIndex = value
	}

	@IBAction func restSetsSecondsValueChanged(_ value: Int) {
		activityConfiguration.restBetweenSets.secondsIndex = value
	}

	// MARK: - Rest between exercises time counter

	@IBAction func increaseExercisesRestTimeButtonTapped() {
		activityConfiguration.restBetweenExercises.rawValue += 5
		let storedSeconds = activityConfiguration.restBetweenExercises.rawValue
		restExercisesMinutePicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.minutesIndex)
		activityConfiguration.restBetweenExercises.rawValue = storedSeconds
		restExercisesSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.secondsIndex)
	}

	@IBAction func decreaseExercisesRestTimeButtonTapped() {
		activityConfiguration.restBetweenExercises.rawValue -= 5
		let storedSeconds = activityConfiguration.restBetweenExercises.rawValue
		restExercisesMinutePicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.minutesIndex)
		activityConfiguration.restBetweenExercises.rawValue = storedSeconds
		restExercisesSecondsPicker.setSelectedItemIndex(activityConfiguration.restBetweenExercises.secondsIndex)
	}

	@IBAction func restExercisesMinutesValueChanged(_ value: Int) {
		activityConfiguration.restBetweenExercises.minutesIndex = value
	}

	@IBAction func restExercisesSecondsValueChanged(_ value: Int) {
		activityConfiguration.restBetweenExercises.secondsIndex = value
	}

}
