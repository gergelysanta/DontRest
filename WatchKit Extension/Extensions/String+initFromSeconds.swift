//
//  String+initFromSeconds.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 26/07/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import UIKit

extension String {

	init(fromSeconds: UInt) {

		// Create mutable variable from immutable
		var seconds = fromSeconds

		let hours = seconds / 3600
		seconds -= hours * 3600

		let minutes = seconds / 60
		seconds -= minutes * 60

		if hours > 0 {
			self = "\(hours)h \(minutes)m \(seconds)s"
		}
		else if minutes > 0 {
			self = "\(minutes)m \(seconds)s"
		}
		else {
			self = "\(seconds)s"
		}
	}

}
