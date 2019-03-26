//
//  MainInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 24/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation

class MainInterfaceController: WKInterfaceController {

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)		
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	// MARK: - Start button

	@IBAction func startButtonTapped() {
		WKInterfaceController.reloadRootControllers(withNames: ["WorkoutInterface"], contexts: nil)
	}

}
