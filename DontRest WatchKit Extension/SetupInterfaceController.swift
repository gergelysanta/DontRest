//
//  SetupInterfaceController.swift
//  DontRest WatchKit Extension
//
//  Created by Gergely Sánta on 24/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class SetupInterfaceController: WKInterfaceController {

	@IBOutlet var activityPicker: WKInterfacePicker!

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var activityItems = [WKPickerItem]()
		for activity in Configuration.shared.availableActivities {
			let item = WKPickerItem()
			item.title = activity.name
			activityItems.append(item)
		}
		activityPicker.setItems(activityItems)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	@IBAction func activityPickerChanged(_ value: Int) {
		Configuration.shared.activity = Configuration.shared.availableActivities[value].type
		#if DEBUG
		NSLog("Workout selected: \(Configuration.shared.availableActivities[value].name)")
		#endif
	}
	
}
