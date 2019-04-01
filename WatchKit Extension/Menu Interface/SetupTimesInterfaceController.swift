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

	private var minutesValue:Int = Configuration.shared.restBetweenSets.seconds / 60
	private var secondsValue:Int = Configuration.shared.restBetweenSets.seconds % 60

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		let configuration = Configuration.shared

		// Fill up rest minutes picker with values
		var minutesItems = [WKPickerItem]()
		for minute in configuration.restBetweenSets.availableMinutes {
			let item = WKPickerItem()
			item.title = "\(minute)"
			minutesItems.append(item)
		}
		restSetsTimeMinutesPicker.setItems(minutesItems)
		restSetsTimeMinutesPicker.setSelectedItemIndex(configuration.restBetweenSets.minutesIndex)
		restExercisesMinutePicker.setItems(minutesItems)
		restExercisesMinutePicker.setSelectedItemIndex(configuration.restBetweenExercises.minutesIndex)

		// Fill up rest seconds picker with values
		var secondsItems = [WKPickerItem]()
		for seconds in configuration.restBetweenSets.availableSeconds {
			let item = WKPickerItem()
			item.title = String(format: "%02d", seconds)
			secondsItems.append(item)
		}
		restSetsTimeSecondsPicker.setItems(secondsItems)
		restSetsTimeSecondsPicker.setSelectedItemIndex(configuration.restBetweenSets.secondsIndex)
		restExercisesSecondsPicker.setItems(secondsItems)
		restExercisesSecondsPicker.setSelectedItemIndex(configuration.restBetweenExercises.secondsIndex)
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
		Configuration.shared.restBetweenSets.seconds += 5
		let storedSeconds = Configuration.shared.restBetweenSets.seconds
		restSetsTimeMinutesPicker.setSelectedItemIndex(Configuration.shared.restBetweenSets.minutesIndex)
		Configuration.shared.restBetweenSets.seconds = storedSeconds
		restSetsTimeSecondsPicker.setSelectedItemIndex(Configuration.shared.restBetweenSets.secondsIndex)
	}

	@IBAction func decreaseSetsRestTimeButtonTapped() {
		Configuration.shared.restBetweenSets.seconds -= 5
		let storedSeconds = Configuration.shared.restBetweenSets.seconds
		restSetsTimeMinutesPicker.setSelectedItemIndex(Configuration.shared.restBetweenSets.minutesIndex)
		Configuration.shared.restBetweenSets.seconds = storedSeconds
		restSetsTimeSecondsPicker.setSelectedItemIndex(Configuration.shared.restBetweenSets.secondsIndex)
	}

	@IBAction func restSetsMinutesValueChanged(_ value: Int) {
		Configuration.shared.restBetweenSets.minutesIndex = value
	}

	@IBAction func restSetsSecondsValueChanged(_ value: Int) {
		Configuration.shared.restBetweenSets.secondsIndex = value
	}

	// MARK: - Rest between exercises time counter

	@IBAction func increaseExercisesRestTimeButtonTapped() {
		Configuration.shared.restBetweenExercises.seconds += 5
		let storedSeconds = Configuration.shared.restBetweenExercises.seconds
		restExercisesMinutePicker.setSelectedItemIndex(Configuration.shared.restBetweenExercises.minutesIndex)
		Configuration.shared.restBetweenExercises.seconds = storedSeconds
		restExercisesSecondsPicker.setSelectedItemIndex(Configuration.shared.restBetweenExercises.secondsIndex)
	}

	@IBAction func decreaseExercisesRestTimeButtonTapped() {
		Configuration.shared.restBetweenExercises.seconds -= 5
		let storedSeconds = Configuration.shared.restBetweenExercises.seconds
		restExercisesMinutePicker.setSelectedItemIndex(Configuration.shared.restBetweenExercises.minutesIndex)
		Configuration.shared.restBetweenExercises.seconds = storedSeconds
		restExercisesSecondsPicker.setSelectedItemIndex(Configuration.shared.restBetweenExercises.secondsIndex)
	}

	@IBAction func restExercisesMinutesValueChanged(_ value: Int) {
		Configuration.shared.restBetweenExercises.minutesIndex = value
	}

	@IBAction func restExercisesSecondsValueChanged(_ value: Int) {
		Configuration.shared.restBetweenExercises.secondsIndex = value
	}

}
