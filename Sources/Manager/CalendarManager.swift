//
//  CalendarManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 16/02/25.
//

import EventKit

public protocol CalendarRepository {
	func requestAccess() async throws -> Bool
	
	func addEvent(title: String, startDate: Date, endDate: Date) async -> Result<String,Error>
	
	func removeEvent(eventIdentifier: String) async -> Result<Void,Error>
}

public class CalendarManager: ObservableObject,CalendarRepository {
	private let eventStore = EKEventStore()
	
	public init() {
	}
	
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
	
	public func addEvent(title: String, startDate: Date, endDate: Date) async -> Result<String,Error> {
		do {
			let granted = try await requestAccess()
			guard granted else {
				return .failure(NSError(domain: "CalendarError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Accesso al calendario negato"]))
			}
		} catch {
			return .failure(error)
		}
		
		let event = EKEvent(eventStore: eventStore)
		event.title = title
		event.startDate = startDate
		let adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate
		event.endDate = adjustedEndDate
		event.calendar = eventStore.defaultCalendarForNewEvents
		
		do {
			try eventStore.save(event, span: .thisEvent)
			return .success(event.eventIdentifier)
		} catch {
			return .failure(error)
		}
	}
	
	public func removeEvent(eventIdentifier: String) async -> Result<Void,Error> {
		guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
			return .failure(NSError(domain: "CalendarError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Evento non trovato"]))
		}
		
		do {
			try eventStore.remove(event, span: .thisEvent)
			return .success(())
		} catch {
			return .failure(error)
		}
	}
}

public class CalendarManagerMock: CalendarRepository {
	
	public init() {}
	
	public func requestAccess() async throws -> Bool { return true }
	
	public func addEvent(title: String, startDate: Date, endDate: Date) async -> Result<String,Error> {return .success("")}
	
	public func removeEvent(eventIdentifier: String) async -> Result<Void,Error> {return .success(()) }
	
}
