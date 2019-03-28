//
//  WorkoutInterfaceController.swift
//  WatchKit Extension
//
//  Created by Gergely Sánta on 25/03/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class WorkoutInterfaceController: WKInterfaceController {

	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var heartRateUnitLabel: WKInterfaceLabel!
	@IBOutlet var infoLabel: WKInterfaceLabel!
	@IBOutlet var energyLabel: WKInterfaceLabel!
	@IBOutlet var endButton: WKInterfaceButton!

	var healthStore: HKHealthStore?
	var activeDataQueries = [HKQuery]()

	var workoutSession: HKWorkoutSession?
	var workoutIsActive = false
	var workoutStartDate = Date()
	var workoutStopDate = Date()

	var totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0.0)
	var lastHeartRate = 0.0
	var countPerMinuteUnit = HKUnit(from: "count/min")

	func display(error: String) {
		heartRateLabel.setHidden(true)
		heartRateUnitLabel.setHidden(true)
		energyLabel.setHidden(true)
		infoLabel.setText(error)
	}

	override func awake(withContext context: Any?) {
        super.awake(withContext: context)

		if !HKHealthStore.isHealthDataAvailable() {
			display(error: "Health data not available")
		}

		// Configure the values we want to write
		let writeTypes: Set<HKSampleType> = [
			.workoutType(),
			HKSampleType.quantityType(forIdentifier: .heartRate)!,
			HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
		]

		// Configure the values we want to read
		let readTypes: Set<HKObjectType> = [
			.activitySummaryType(),
			.workoutType(),
			HKObjectType.quantityType(forIdentifier: .heartRate)!,
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
		]

		// Request authorization for our types
		let healthStore = HKHealthStore()
		self.healthStore = healthStore

		healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success:Bool, error:Error?) in
			if success {
				// Start workout
				let config = HKWorkoutConfiguration()
				config.activityType = Configuration.shared.activity
				config.locationType = .indoor

				do {
					let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)

					self.workoutSession = session
					self.workoutStartDate = Date()
					session.delegate = self
					session.startActivity(with: self.workoutStartDate)
				}
				catch let error as NSError {
					self.display(error: error.localizedDescription)
				}
			}
			else {
				self.display(error: "HealthKit not authorized")
			}
		}
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	@IBAction func endButtonTapped() {
		workoutStopDate = Date()
		workoutSession?.end()
		endButton.setEnabled(false)
	}

	private func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) -> Bool {
		guard let sampleType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else { return false }

		// We need data only counting from our workout start date
		let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate,
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
		healthStore?.execute(query)

		// Add it to our queue so we can stop it later
		activeDataQueries.append(query)

		return true
	}

	func startQueries() {
		if !startQuery(quantityTypeIdentifier: .heartRate) ||
			!startQuery(quantityTypeIdentifier: .activeEnergyBurned)
		{
			display(error: "Could not register queries in HealthKit")
		}
		else {
			// Play start sound/haptic feedback
			WKInterfaceDevice.current().play(WKHapticType.start)
		}
	}

	func stopQueries() {
		for query in activeDataQueries {
			healthStore?.stop(query)
		}
		activeDataQueries.removeAll()
	}

	func save(session: HKWorkoutSession) {
		guard healthStore?.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
		else {
			NSLog("ERROR: the app does not have permission to save workout samples")
			return
		}

		let workout = HKWorkout(activityType: session.workoutConfiguration.activityType,
								start: workoutStartDate,
								end: workoutStopDate,
								workoutEvents: nil,
								totalEnergyBurned: totalEnergyBurned,
								totalDistance: nil,
								metadata: [HKMetadataKeyIndoorWorkout: true])
		healthStore?.save(workout) { (success:Bool, error:Error?) in
			if success {
				// Dismiss the view controller (go back to main screen)
				DispatchQueue.main.sync {
					self.dismiss()
				}
			}
		}
	}

	func process(samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
		guard workoutIsActive else { return }

		for sample in samples {
			if type == .heartRate {
				lastHeartRate = sample.quantity.doubleValue(for: countPerMinuteUnit)

				// Update label
				heartRateLabel.setText(String(format: "%.0f", lastHeartRate))
			}
			else if type == .activeEnergyBurned {
				let newEnergy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
				let currentEnergy = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
				totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: currentEnergy + newEnergy)

				// Update label
				let kiloCalories = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
				energyLabel.setText(String(format: "%.0f kCal", kiloCalories))
			}
		}
	}

}

extension WorkoutInterfaceController: HKWorkoutSessionDelegate {

	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		#if DEBUG
		NSLog("-- Workout state change: \(fromState.description) -> \(toState.description)")
		#endif
		switch toState {
		case .running:
			if fromState == .notStarted {
				// Workout just started: start querying data
				startQueries()
			}
			workoutIsActive = true
		case .paused:
			workoutIsActive = false
		case .ended:
			workoutIsActive = false
			stopQueries()
			save(session: workoutSession)
		default:
			break
		}
	}

	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		NSLog("Workout session failed: \(error.localizedDescription)")
	}

}

extension HKWorkoutSessionState {

	var description:String {
		switch self {
		case .notStarted:
			return "notStarted"
		case .paused:
			return "paused"
		case .prepared:
			return "prepared"
		case .running:
			return "running"
		case .stopped:
			return "stopped"
		case .ended:
			return "ended"
		@unknown default:
			return "UNKNOWN[\(rawValue)]"
		}
	}

}
