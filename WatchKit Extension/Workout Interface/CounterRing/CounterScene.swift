//
//  CounterScene.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 03/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import SpriteKit

protocol CounterSceneDelegate: SKSceneDelegate {
	func counterTick(seconds: Int)
	func counterEnded()
}

class CounterScene: SKScene {

	private var arcSprite:SKShapeNode!
	private var backgroundArcSprite:SKShapeNode!
	private var labelSprite:SKLabelNode!
	private var counterStartTime:TimeInterval? = nil
	private var animating = false

	private var duration = TimeInterval(0)
	private var elapsedFullSeconds:Int = 0

	override init() {
		super.init()
		initializeCounter()
	}

	override init(size: CGSize) {
		super.init(size: size)
		initializeCounter()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeCounter()
	}

	var radius:CGFloat {
		return ((size.width < size.height) ? size.width : size.height) * 0.4
	}

	func start() {
		self.start(withDuration: 3)
	}

	func start(withDuration: TimeInterval) {
		counterStartTime = nil
		duration = withDuration
		animating = true

		setCounter(time: Int(duration))
	}

	func stop() {
		counterStartTime = nil
		duration = 0
		animating = false
	}

	private func setCounter(time: Int) {
		labelSprite.text = "\(time)"

		let scaleIn = SKAction.scale(to: 1.5, duration: 0.15)
		let scaleOut = SKAction.scale(to: 1.0, duration: 0.15)
		labelSprite.run(SKAction.sequence([scaleIn, scaleOut]))

		(delegate as? CounterSceneDelegate)?.counterTick(seconds: elapsedFullSeconds)
	}

	private func initializeCounter() {
		let centerPoint = CGPoint(x: size.width/2, y: size.height/2)

		arcSprite = SKShapeNode(circleOfRadius: radius)
		arcSprite.position = centerPoint
		arcSprite.strokeColor = SKColor.green
		arcSprite.lineWidth = 10.0
		arcSprite.lineCap = .round
		arcSprite.alpha = 0.0
		self.addChild(arcSprite)

		backgroundArcSprite = SKShapeNode(circleOfRadius: radius)
		backgroundArcSprite.position = centerPoint
		backgroundArcSprite.strokeColor = SKColor.green
		backgroundArcSprite.lineWidth = 10.0
		backgroundArcSprite.lineCap = .round
		backgroundArcSprite.alpha = 0.2
		backgroundArcSprite.zPosition = -1.0
		self.addChild(backgroundArcSprite)

		labelSprite = SKLabelNode()
		labelSprite.verticalAlignmentMode = .center
		labelSprite.horizontalAlignmentMode = .center
		labelSprite.fontName = "Courier-Bold"
		labelSprite.fontSize = 84
		labelSprite.fontColor = SKColor.green
		labelSprite.position = centerPoint
		self.addChild(labelSprite)
	}

	private func updateArc(withProgress progress: Double) {
		let startAngle = CGFloat(90.0 * Double.pi / 180)
		let progressAngle = CGFloat(360.0 * progress * Double.pi / 180)

		arcSprite.path = UIBezierPath(arcCenter: CGPoint.zero,
									  radius: radius,
									  startAngle: startAngle,
									  endAngle: startAngle - progressAngle,
									  clockwise: false).cgPath
		arcSprite.alpha = 1.0
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)

		// Do nothing if counter not started yet
		guard animating == true else { return }

		// Mark animation start time if not yet marked (we just started the counter)
		guard let startTime = counterStartTime else {
			counterStartTime = currentTime
			return
		}

		// Count elapsed time
		let elapsedTime = currentTime - startTime
		let newElapsedFullSeconds = Int(elapsedTime)

		let progress = elapsedTime / duration
		updateArc(withProgress: progress)

		// Check is timer ended
		if elapsedTime > duration {
			(delegate as? CounterSceneDelegate)?.counterEnded()
			stop()
			return
		}

		// Check if new second passed
		if elapsedFullSeconds != newElapsedFullSeconds {
			elapsedFullSeconds = newElapsedFullSeconds
			setCounter(time: Int(duration) - elapsedFullSeconds)
		}
	}

}
