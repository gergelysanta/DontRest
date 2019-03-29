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

	@IBOutlet var timer: WKInterfaceTimer!
	@IBOutlet var errorLabel: WKInterfaceLabel!
	@IBOutlet var heartRateLabel: WKInterfaceLabel!
	@IBOutlet var activeEnergyLabel: WKInterfaceLabel!
	@IBOutlet var totalEnergyLabel: WKInterfaceLabel!

	@IBOutlet var heartRateGroup: WKInterfaceGroup!
	@IBOutlet var activeEnergyGroup: WKInterfaceGroup!
	@IBOutlet var totalEnergyGroup: WKInterfaceGroup!

	@IBOutlet var endButton: WKInterfaceButton!

	var healthStore: HKHealthStore?
	var activeDataQueries = [HKQuery]()

	var workoutSession: HKWorkoutSession?
	var workoutIsActive = false
	var workoutStartDate = Date()
	var workoutStopDate = Date()

	var activeEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0.0)
	var totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0.0)
	var lastHeartRate = 0.0
	var countPerMinuteUnit = HKUnit(from: "count/min")

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

	// -------------------------

	private func display(error: String) {
		errorLabel.setText(error)
		errorLabel.setHidden(false)
		timer.setHidden(true)
		heartRateGroup.setHidden(true)
		activeEnergyGroup.setHidden(true)
		totalEnergyGroup.setHidden(true)
	}

	@IBAction func endButtonTapped() {
		if let session = workoutSession {
			// Remember stop date and end the workout
			workoutStopDate = Date()
			session.end()
			// Disable "End" button to prevent multiple taps
			endButton.setEnabled(false)
		}
		else {
			// We don't have running workout session, simply dismiss this view
			dismiss()
		}
	}

	/// Start a query in HealthStore
	///
	/// - Parameter quantityTypeIdentifier: identifier of quantity which we want to query
	/// - Returns: Query started successfully or not
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

	/// Start all queryes for this workout
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

	/// Stop workout queries
	func stopQueries() {
		for query in activeDataQueries {
			healthStore?.stop(query)
		}
		activeDataQueries.removeAll()
	}

	/// Save session
	///
	/// - Parameter session: workout session
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

	/// Process data received from HealthKit
	///
	/// - Parameters:
	///   - samples: received samples
	///   - type: quantity type of samples
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

				// Update labels
				let kiloCalories = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
				activeEnergyLabel.setText(String(format: "%.0f", newEnergy))
				totalEnergyLabel.setText(String(format: "%.0f", kiloCalories))
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
				// Start timer
				timer.start()
			}
			workoutIsActive = true
		case .paused:
			workoutIsActive = false
		case .ended:
			workoutIsActive = false
			timer.stop()
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
