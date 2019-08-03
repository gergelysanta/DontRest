//
//  WorkoutCounterInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 02/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import SpriteKit

class WorkoutCounterInterfaceController: WKInterfaceController {

	@IBOutlet weak var counterInterface: WKInterfaceSKScene!
	private var counterScene: CounterScene!
	private var configuration: Any?

	override func awake(withContext context: Any?) {
		counterScene = CounterScene(size: contentFrame.size)
		counterScene.scaleMode = .aspectFit
		counterScene.backgroundColor = UIColor.clear
		counterScene.delegate = self
		counterInterface.presentScene(counterScene)

		configuration = context
	}

	override func didAppear() {
		super.didAppear()
		counterScene.start()
	}

}

extension WorkoutCounterInterfaceController: CounterSceneDelegate {

	func counterTick(seconds: Int) {
		WKInterfaceDevice.current().play(.click)
	}

	func counterEnded() {
		var contexts:[Any]? = nil
		if let configuration = configuration {
			contexts = [configuration, configuration, configuration]
		}
		WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutControlController","WorkoutMainController","WorkoutMusicController"],
														contexts: contexts,
														orientation: .horizontal,
														pageIndex: 1)
	}

}
