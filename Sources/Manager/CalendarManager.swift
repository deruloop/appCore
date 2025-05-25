//
//  CalendarManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 16/02/25.
//

import EventKit
import EventKitUI
import UIKit

public protocol CalendarRepository {
	func requestAccess() async throws -> Bool

	func addEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool) async -> Result<String, Error>

	func removeEvent(eventIdentifier: String) async -> Result<Void, Error>
	
	func addEventWithEditing(
		from viewController: UIViewController,
		title: String,
		startDate: Date,
		endDate: Date,
		isAllDay: Bool
	) async -> Result<String, Error>
}

public class CalendarManager: NSObject, ObservableObject, CalendarRepository {
	private let eventStore = EKEventStore()
	
	/// Used to resume the async call once user is done editing.
	private var editingContinuation: CheckedContinuation<Result<String, Error>, Never>?

	public override init() {
		super.init()
	}
	
	// MARK: - 1) Request Calendar Access
	public func requestAccess() async throws -> Bool {
		return try await withCheckedThrowingContinuation { continuation in
			eventStore.requestAccess(to: .event) { granted, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: granted)
				}
			}
		}
	}
	
	// MARK: - 2) Directly Add Event (No User Edit)
	public func addEvent(title: String, startDate: Date, endDate: Date,
	isAllDay: Bool) async -> Result<String, Error> {
		do {
			let granted = try await requestAccess()
			guard granted else {
				return .failure(NSError(
					domain: "CalendarManagerError",
					code: 1,
					userInfo: [NSLocalizedDescriptionKey: "Accesso al calendario negato"]
				))
			}
		} catch {
			return .failure(error)
		}
		
		let event = EKEvent(eventStore: eventStore)
		event.isAllDay = isAllDay
		event.title = title
		event.startDate = startDate
		event.endDate = endDate
		event.calendar = eventStore.defaultCalendarForNewEvents
		
		do {
			try eventStore.save(event, span: .thisEvent)
			return .success(event.eventIdentifier)
		} catch {
			return .failure(error)
		}
	}
	
	// MARK: - 3) Remove Event
	public func removeEvent(eventIdentifier: String) async -> Result<Void, Error> {
		guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
			return .failure(NSError(
				domain: "CalendarError",
				code: 2,
				userInfo: [NSLocalizedDescriptionKey: "Evento non trovato"]
			))
		}
		
		do {
			try eventStore.remove(event, span: .thisEvent)
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	// MARK: - 4) Add Event With Edit Screen
	public func addEventWithEditing(
		from viewController: UIViewController,
		title: String,
		startDate: Date,
		endDate: Date,
		isAllDay: Bool
	) async -> Result<String, Error> {
		do {
			let granted = try await requestAccess()
			guard granted else {
				return .failure(NSError(
					domain: "CalendarError",
					code: 1,
					userInfo: [NSLocalizedDescriptionKey: "Access denied"]
				))
			}
		} catch {
			return .failure(error)
		}
		
		// Prepare the event
		let event = EKEvent(eventStore: eventStore)
		event.title = title
		event.isAllDay = isAllDay
		event.startDate = startDate
		event.endDate = endDate
		event.calendar = eventStore.defaultCalendarForNewEvents
		
		// Present the native UI using a CheckedContinuation
		return await withCheckedContinuation { continuation in
			self.editingContinuation = continuation
			
			DispatchQueue.main.async {
				let editVC = EKEventEditViewController()
				editVC.eventStore = self.eventStore
				editVC.event = event
				editVC.editViewDelegate = self
				viewController.present(editVC, animated: true)
			}
		}
	}
}

// MARK: - EKEventEditViewDelegate
extension CalendarManager: EKEventEditViewDelegate {
	public func eventEditViewController(
		_ controller: EKEventEditViewController,
		didCompleteWith action: EKEventEditViewAction
	) {
		defer { controller.dismiss(animated: true) }
		
		switch action {
		case .saved:
			// If user saved, return the event identifier
			if let eventID = controller.event?.eventIdentifier {
				editingContinuation?.resume(returning: .success(eventID))
			} else {
				editingContinuation?.resume(returning: .failure(NSError(
					domain: "CalendarError",
					code: 2,
					userInfo: [NSLocalizedDescriptionKey: "Failed to get event ID"]
				)))
			}
		case .canceled, .deleted:
			// Both canceled & deleted = not saved
			editingContinuation?.resume(returning: .failure(NSError(
				domain: "CalendarError",
				code: 3,
				userInfo: [NSLocalizedDescriptionKey: "Event not saved"]
			)))
		@unknown default:
			editingContinuation?.resume(returning: .failure(NSError(
				domain: "CalendarError",
				code: 4,
				userInfo: [NSLocalizedDescriptionKey: "Unknown edit action"]
			)))
		}
		
		editingContinuation = nil
	}
}

public class CalendarManagerMock: CalendarRepository {
	
	public init() {}
	
	public func requestAccess() async throws -> Bool { return true }
	
	public func addEvent(title: String, startDate: Date, endDate: Date, isAllDay: Bool) async -> Result<String,Error> {return .success("")}
	
	public func removeEvent(eventIdentifier: String) async -> Result<Void,Error> {return .success(()) }
	
	public func addEventWithEditing(from viewController: UIViewController, title: String, startDate: Date, endDate: Date, isAllDay: Bool) async -> Result<String, any Error> {
		return .success("")
	}
	
}
