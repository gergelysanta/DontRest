//
//  Workout.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 29/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

protocol WorkoutDelegate: AnyObject {
	func workoutDidStart(_ workout: Workout)
	func workoutDidStop(_ workout: Workout)
	func workout(_ workout: Workout, errorReceived error: String)
	func workout(_ workout: Workout, valueChanged: Workout.ValueType)
}

class Workout: NSObject {

	static let shared = Workout()

	static var isAvailable:Bool {
		return HKHealthStore.isHealthDataAvailable()
	}

	enum ValueType {
		case lastHeartRate
		case activeEnergyBurned
		case totalEnergyBurned
	}

	weak var delegate:WorkoutDelegate?

	private var workoutSession: HKWorkoutSession?

	/// Flag indicating if workout is started. It's not necessarily collecting data in this state. Flag is set to true if start was requested and to false if stop was requested.
	private(set) var isStarted = false

	/// Flag indicating if workout is active and is collecting data from HealthKit
	private(set) var isActive = false

	/// Date when workout started
	private(set) var startDate = Date()

	/// Date when workout stopped
	private(set) var stopDate:Date?

	/// Last measured hearth rate
	@objc private(set) var lastHeartRate:Double = 0.0 {
		didSet {
			delegate?.workout(self, valueChanged: .lastHeartRate)
		}
	}

	/// Last measured active energy
	@objc private(set) var activeEnergyBurned:Double = 0.0 {
		didSet {
			delegate?.workout(self, valueChanged: .activeEnergyBurned)
		}
	}

	/// Last measured total energy
	@objc private(set) var totalEnergyBurned:Double = 0.0 {
		didSet {
			delegate?.workout(self, valueChanged: .totalEnergyBurned)
		}
	}

	private let healthStore = HKHealthStore()
	private var activeDataQueries = [HKQuery]()

	private let countPerMinuteUnit = HKUnit(from: "count/min")

	// Hide default constructor, this object is a singleton
	private override init() {
		super.init()
	}

	/// Start workout activity
	///
	/// - Parameter activity: HealthKit activity type
	func start(withActivity activity: HKWorkoutActivityType) {
		if isStarted { return }
		isStarted = true

		// Configure the values we want to write to HealthKit
		let writeTypes: Set<HKSampleType> = [
			.workoutType(),
			HKSampleType.quantityType(forIdentifier: .heartRate)!,
			HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
		]

		// Configure the values we want to read from HealthKit
		let readTypes: Set<HKObjectType> = [
			.activitySummaryType(),
			.workoutType(),
			HKObjectType.quantityType(forIdentifier: .heartRate)!,
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
		]

		// Request authorization for our types
		healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success:Bool, error:Error?) in
			if success {
				// Start workout
				let config = HKWorkoutConfiguration()
				config.activityType = activity
				config.locationType = .indoor

				do {
					let session = try HKWorkoutSession(healthStore: self.healthStore, configuration: config)

					self.startDate = Date()
					self.stopDate = nil

					self.workoutSession = session
					session.delegate = self
					session.startActivity(with: self.startDate)
					DispatchQueue.main.sync {
						self.delegate?.workoutDidStart(self)
					}
				}
				catch let error as NSError {
					self.isStarted = false
					self.isActive = false
					self.delegate?.workout(self, errorReceived: error.localizedDescription)
				}
			}
			else {
				self.isStarted = false
				self.isActive = false
				self.delegate?.workout(self, errorReceived: "HealthKit not authorized")
			}
		}
	}

	func stop() {
		if isStarted {
			isStarted = false
			self.stopDate = Date()
			workoutSession?.end()
		}
	}

	/// Start a query in HealthStore
	///
	/// - Parameter quantityTypeIdentifier: identifier of quantity which we want to query
	/// - Returns: Query started successfully or not
	private func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) -> Bool {
		guard let sampleType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else { return false }

		// We need data only counting from our workout start date
		let datePredicate = HKQuery.predicateForSamples(withStart: startDate,
														end: nil,
														options: .strictStartDate)

		// We need data only from this device
		let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

		let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])

		// Code receiving data from our predicates
		let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void =
		{ (query, samples, deletedObjects, queryAnchor, error) in
			// Typecast to quantity sample
			guard let samples = samples as? [HKQuantitySample] else { return }

			self.process(samples: samples, type: quantityTypeIdentifier)
		}

		// Create the query
		let query = HKAnchoredObjectQuery(type: sampleType,
										  predicate: queryPredicate,
										  anchor: nil,
										  limit: HKObjectQueryNoLimit,
										  resultsHandler: updateHandler)

		// Re-run the code every time new data is available
		query.updateHandler = updateHandler

		// Start query
		healthStore.execute(query)

		// Add it to our queue so we can stop it later
		activeDataQueries.append(query)

		return true
	}

	/// Start all queryes for this workout
	private func startQueries() -> Bool {
		if !startQuery(quantityTypeIdentifier: .heartRate) ||
		   !startQuery(quantityTypeIdentifier: .activeEnergyBurned)
		{
			delegate?.workout(self, errorReceived: "Could not register queries in HealthKit")
			return false
		}
		// Play start sound/haptic feedback
		WKInterfaceDevice.current().play(WKHapticType.start)
		return true
	}

	/// Stop workout queries
	private func stopQueries() {
		for query in activeDataQueries {
			healthStore.stop(query)
		}
		activeDataQueries.removeAll()
		// Play start sound/haptic feedback
		WKInterfaceDevice.current().play(WKHapticType.stop)
	}

	/// Process data received from HealthKit
	///
	/// - Parameters:
	///   - samples: received samples
	///   - type: quantity type of samples
	private func process(samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
		guard isActive else { return }

		for sample in samples {
			if type == .heartRate {
				lastHeartRate = sample.quantity.doubleValue(for: countPerMinuteUnit)
			}
			else if type == .activeEnergyBurned {
				activeEnergyBurned = sample.quantity.doubleValue(for: HKUnit.kilocalorie())

				let newTotalEnergy = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalEnergyBurned + activeEnergyBurned)
				totalEnergyBurned = newTotalEnergy.doubleValue(for: HKUnit.kilocalorie())
			}
		}
	}

	/// Save session
	///
	/// - Parameter session: workout session
	private func save(session: HKWorkoutSession) {
		guard healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else {
			NSLog("ERROR: the app does not have permission to save workout samples")
			isActive = false
			return
		}

		let workout = HKWorkout(activityType: session.workoutConfiguration.activityType,
								start: startDate,
								end: stopDate ?? Date(),
								workoutEvents: nil,
								totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: totalEnergyBurned),
								totalDistance: nil,
								metadata: [HKMetadataKeyIndoorWorkout: true])
		healthStore.save(workout) { (success:Bool, error:Error?) in
			if success {
				self.isActive = false
			}
			else {
				self.delegate?.workout(self, errorReceived: "Could not save workout to HealtKit")
			}
		}
	}

}

extension Workout: HKWorkoutSessionDelegate {

	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		#if DEBUG
		NSLog("-- Workout state change: \(fromState.description) -> \(toState.description)")
		#endif
		switch (fromState, toState) {

		case (.notStarted, .running):
			// Workout just started: start querying data
			if startQueries() {
				// We're now receiving data from HealthKit - workout started
				isActive = true
			}
			else {
				// We're not receiving data from HealthKit, stop workout
				stop()
			}

		case (_, .paused):
			// TODO: Handle also pause event
			break

		case (_, .ended):
			stopQueries()
			save(session: workoutSession)
			DispatchQueue.main.sync {
				delegate?.workoutDidStop(self)
			}

		default:
			break
		}
	}

	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		delegate?.workout(self, errorReceived: error.localizedDescription)
		stop()
	}

}
