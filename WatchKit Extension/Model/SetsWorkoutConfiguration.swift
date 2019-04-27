//
//  SetsWorkoutConfiguration.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 12/04/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation
import HealthKit

class SetsWorkoutConfiguration: BaseWorkoutConfiguration, Codable {

	// Sets count
	var sets = RangedInt(rawValue: 3)

	// Length of allowed rest between sets
	var restBetweenSets = RangedTime(rawValue: 60)			// 1 minute

	// Length of allowed rest between exercises sets
	var restBetweenExercises = RangedTime(rawValue: 180)	// 3 minutes

	override init(_ type: HKWorkoutActivityType) {
		super.init(type)
	}

	// MARK: - Serialization

	private enum CodingKeys: String, CodingKey {
		case type
		case length
		case sets
		case restBetweenSets
		case restBetweenExercises
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		// Encode BaseWorkoutConfiguration
		try container.encode(type.rawValue, forKey: .type)
		try container.encode(length, forKey: .length)

		// Encode SetsWorkoutConfiguration
		try container.encode(sets.rawValue, forKey: .sets)
		try container.encode(restBetweenSets.rawValue, forKey: .restBetweenSets)
		try container.encode(restBetweenExercises.rawValue, forKey: .restBetweenExercises)
	}

	// Initializing object from serialized data
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		var rawValue:Int

		// Decode BaseWorkoutConfiguration
		let rawType = try values.decode(UInt.self, forKey: .type)
		super.init(HKWorkoutActivityType(rawValue: rawType) ?? .other)

		length = (try? values.decode(UInt.self, forKey: .length)) ?? 0

		// Decode SetsWorkoutConfiguration
		rawValue = try values.decode(Int.self, forKey: .sets)
		sets = RangedInt(rawValue: rawValue)

		rawValue = try values.decode(Int.self, forKey: .restBetweenSets)
		restBetweenSets = RangedTime(rawValue: rawValue)

		rawValue = try values.decode(Int.self, forKey: .restBetweenExercises)
		restBetweenExercises = RangedTime(rawValue: rawValue)
	}

}
