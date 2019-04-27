//
//  RangedInt.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 26/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation

class RangedInt {

	let availableValues:[Int] = Array(1...99)

	var rawValue:Int = 1 {
		didSet {
			guard
				let lowestValue = availableValues.first,
				let highestValue = availableValues.last
				else {
					return
			}
			if rawValue < lowestValue {
				rawValue = lowestValue
			}
			else if rawValue > highestValue {
				rawValue = highestValue
			}
		}
	}

	var valueIndex:Int {
		get {
			if let index = availableValues.firstIndex(of: rawValue) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableValues.count) {
				rawValue = availableValues[newValue]
				#if DEBUG
				NSLog("RangedInt: \(rawValue)")
				#endif
			}
		}
	}

	init(rawValue: Int) {
		self.rawValue = rawValue
		#if DEBUG
		NSLog("RangedInt: \(self.rawValue)")
		#endif
	}

}
