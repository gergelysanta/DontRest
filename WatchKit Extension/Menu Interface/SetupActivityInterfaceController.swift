//
//  SetupActivityInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 24/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class SetupActivityInterfaceController: WKInterfaceController {

	@IBOutlet var setsCountPicker: WKInterfacePicker!

	private var activityConfiguration:SetsWorkoutConfiguration!

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		if let configuration = context as? SetsWorkoutConfiguration {
			activityConfiguration = configuration
		} else {
			dismiss()
			return
		}

		// Fill up "Sets" picker with values
		var setsItems = [WKPickerItem]()
		for count in activityConfiguration.sets.availableValues {
			let item = WKPickerItem()
			item.title = "\(count)"
			setsItems.append(item)
		}
		setsCountPicker.setItems(setsItems)
		setsCountPicker.setSelectedItemIndex(activityConfiguration.sets.valueIndex)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	// MARK: - Sets counter

	@IBAction func increaseSetsButtonTapped() {
		activityConfiguration.sets.rawValue += 1
		setsCountPicker.setSelectedItemIndex(activityConfiguration.sets.valueIndex)
	}

	@IBAction func decreaseSetsButtonTapped() {
		activityConfiguration.sets.rawValue -= 1
		setsCountPicker.setSelectedItemIndex(activityConfiguration.sets.valueIndex)
	}

	@IBAction func setsPickerValueChanged(_ value: Int) {
		activityConfiguration.sets.valueIndex = value
	}

}
