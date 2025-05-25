//
//  NotificationManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 25/02/25.
//
import Foundation
import UserNotifications

public protocol NotificationRepository {
	/// Richiede all'utente l'autorizzazione a ricevere notifiche
	func requestAuthorization() async throws -> Bool
	
	/// Programma una notifica locale
	func scheduleNotification(
		identifier: String,
		title: String,
		body: String,
		dateComponents: DateComponents,
		repeats: Bool
	) async -> Result<Void, Error>
	
	/// Rimuove una notifica già programmata
	func removeNotification(identifier: String) async -> Result<Void, Error>
	
	/// Rimuove tutte le notifiche pendenti
	func removeAllNotifications() async -> Result<Void, Error>
}

public class NotificationManager: NotificationRepository {
	public init() {}
	
	// 1. Richiede permessi
	public func requestAuthorization() async throws -> Bool {
		let center = UNUserNotificationCenter.current()
		
		return try await withCheckedThrowingContinuation { continuation in
			let options: UNAuthorizationOptions = [.alert, .sound, .badge]
			center.requestAuthorization(options: options) { granted, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: granted)
				}
			}
		}
	}
	
	// 2. Programma una notifica locale
	public func scheduleNotification(
		identifier: String,
		title: String,
		body: String,
		dateComponents: DateComponents,
		repeats: Bool
	) async -> Result<Void, Error> {
		do {
			let granted = try await requestAuthorization()
			guard granted else {
				return .failure(NSError(
					domain: "NotificationManagerError",
					code: 1,
					userInfo: [NSLocalizedDescriptionKey: "Accesso alle notifiche negato"]
				))
			}
		} catch {
			return .failure(error)
		}
		
		let center = UNUserNotificationCenter.current()
		
		// Contenuto
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = body
		content.sound = .default
		
		// Trigger su base data
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
		
		// Creazione request
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		do {
			try await center.add(request)
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	// 3. Rimuove una notifica
	public func removeNotification(identifier: String) async -> Result<Void, Error> {
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [identifier])
		// Non c'è una vera eccezione lanciata in rimozione, di solito è sempre success
		return .success(())
	}
	
	// 4. Rimuove tutte le notifiche pendenti
	public func removeAllNotifications() async -> Result<Void, Error> {
		let center = UNUserNotificationCenter.current()
		center.removeAllPendingNotificationRequests()
		return .success(())
	}
}

public class NotificationManagerMock: NotificationRepository {
	
	public init() {}

	public func requestAuthorization() async throws -> Bool {
		return true
	}
	
	public func scheduleNotification(
		identifier: String,
		title: String,
		body: String,
		dateComponents: DateComponents,
		repeats: Bool
	) async -> Result<Void, Error> {
		return .success(())
	}
	
	public func removeNotification(identifier: String) async -> Result<Void, Error> {
		return .success(())
	}
	
	public func removeAllNotifications() async -> Result<Void, Error> {
		return .success(())
	}
}
