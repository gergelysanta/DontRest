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

	@IBOutlet var activityPicker: WKInterfacePicker!
	@IBOutlet var setsCountPicker: WKInterfacePicker!

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		// Fill up activities selector
        var activityItems = [WKPickerItem]()
		for activity in Configuration.shared.availableActivities {
			let item = WKPickerItem()
			item.title = activity.name
			activityItems.append(item)
		}
		activityPicker.setItems(activityItems)
		activityPicker.setSelectedItemIndex(Configuration.shared.activityIndex)

		// Fill up "Sets" picker with values
		var setsItems = [WKPickerItem]()
		for count in Configuration.shared.sets.availableValues {
			let item = WKPickerItem()
			item.title = "\(count)"
			setsItems.append(item)
		}
		setsCountPicker.setItems(setsItems)
		setsCountPicker.setSelectedItemIndex(Configuration.shared.sets.valueIndex)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	// MARK: - Activities selector

	@IBAction func activityPickerChanged(_ value: Int) {
		Configuration.shared.activityIndex = value
	}
	
	// MARK: - Sets counter

	@IBAction func increaseSetsButtonTapped() {
		Configuration.shared.sets.value += 1
		setsCountPicker.setSelectedItemIndex(Configuration.shared.sets.valueIndex)
	}

	@IBAction func decreaseSetsButtonTapped() {
		Configuration.shared.sets.value -= 1
		setsCountPicker.setSelectedItemIndex(Configuration.shared.sets.valueIndex)
	}

	@IBAction func setsPickerValueChanged(_ value: Int) {
		Configuration.shared.sets.valueIndex = value
	}

}
