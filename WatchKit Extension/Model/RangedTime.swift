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

	var seconds:Int = 60 {
		didSet {
			guard
				let lowestMinutes = availableMinutes.first,
				let highestMinutes = availableMinutes.last,
				let lowestSeconds = availableSeconds.first,
				let highestSeconds = availableSeconds.last
				else {
					return
			}
			if seconds < (lowestMinutes * 60) + lowestSeconds {
				seconds = (lowestMinutes * 60) + lowestSeconds
			}
			else if seconds > (highestMinutes * 60) + highestSeconds {
				seconds = (highestMinutes * 60) + highestSeconds
			}
			#if DEBUG
			NSLog("RangedTime: \(seconds)s")
			#endif
		}
	}

	var minutesIndex:Int {
		get {
			if let index = availableMinutes.firstIndex(of: seconds / 60) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableMinutes.count) {
				let remainingSeconds = seconds % 60
				seconds = (availableMinutes[newValue] * 60) + remainingSeconds
			}
		}
	}

	var secondsIndex:Int {
		get {
			if let index = availableSeconds.firstIndex(of: seconds % 60) {
				return Int(index)
			}
			return 0
		}
		set {
			if (newValue >= 0) && (newValue < availableSeconds.count) {
				let remainingMinutes = seconds / 60
				seconds = (remainingMinutes * 60) + availableSeconds[newValue]
			}
		}
	}

	init(seconds: Int) {
		var secondsArray:[Int] = []
		var number:Int = 0
		while number < 60 {
			secondsArray.append(number)
			number += 5
		}
		availableSeconds = secondsArray

		self.seconds = seconds
	}

}
