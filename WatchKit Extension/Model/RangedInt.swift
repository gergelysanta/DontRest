//
//  RangedInt.swift
//  DontRest WatchKit Extension
//
//  Created by Gergely Sánta on 26/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation

class RangedInt {

	let availableValues:[Int] = Array(1...99)

	var value:Int = 1 {
		didSet {
			guard
				let lowestValue = availableValues.first,
				let highestValue = availableValues.last
				else {
					return
			}
			if value < lowestValue {
				value = lowestValue
			}
			else if value > highestValue {
				value = highestValue
			}
		}
	}

	var valueIndex:Int {
		get {
			if let index = availableValues.firstIndex(of: value) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableValues.count) {
				value = availableValues[newValue]
				#if DEBUG
				NSLog("RangedInt: \(value)")
				#endif
			}
		}
	}

	init(value: Int) {
		self.value = value
		#if DEBUG
		NSLog("RangedInt: \(self.value)")
		#endif
	}

}
