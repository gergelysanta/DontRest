//
//  RangedTime.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 26/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation

class RangedTime {

	let availableMinutes:[Int] = Array(0...99)
	let availableSeconds:[Int]

	var rawValue:Int = 60 {
		didSet {
			guard
				let lowestMinutes = availableMinutes.first,
				let highestMinutes = availableMinutes.last,
				let lowestSeconds = availableSeconds.first,
				let highestSeconds = availableSeconds.last
				else {
					return
			}
			if rawValue < (lowestMinutes * 60) + lowestSeconds {
				rawValue = (lowestMinutes * 60) + lowestSeconds
			}
			else if rawValue > (highestMinutes * 60) + highestSeconds {
				rawValue = (highestMinutes * 60) + highestSeconds
			}
			#if DEBUG
			NSLog("RangedTime: \(rawValue)s")
			#endif
		}
	}

	var minutesIndex:Int {
		get {
			if let index = availableMinutes.firstIndex(of: rawValue / 60) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableMinutes.count) {
				let remainingSeconds = rawValue % 60
				rawValue = (availableMinutes[newValue] * 60) + remainingSeconds
			}
		}
	}

	var secondsIndex:Int {
		get {
			if let index = availableSeconds.firstIndex(of: rawValue % 60) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableSeconds.count) {
				let remainingMinutes = rawValue / 60
				rawValue = (remainingMinutes * 60) + availableSeconds[newValue]
			}
		}
	}

	init(rawValue: Int) {
		var secondsArray:[Int] = []
		var number:Int = 0
		while number < 60 {
			secondsArray.append(number)
			number += 5
		}
		availableSeconds = secondsArray

		self.rawValue = rawValue
	}

}
