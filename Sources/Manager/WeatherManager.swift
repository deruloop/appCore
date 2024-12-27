//
//  WeatherManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 12/12/24.
//

import Foundation
import WeatherKit
import CoreLocation

public protocol WeatherRepository {
	func fetchDailyWeather(for location: CLLocation, from startDate: Date, to endDate: Date) async -> Result<[DayWeather], Error>
}

public class WeatherManager: ObservableObject,WeatherRepository {
	private let weatherService = WeatherService()
	
	public init() {
	}
	
	public func fetchWeatherWithError(for location: CLLocation) async -> Result<CurrentWeather,Error> {
		do {
			let weather = try await weatherService.weather(for: location)
			return .success(weather.currentWeather)
		} catch {
			return .failure(error)
		}
	}
	
	public func fetchWeather(for location: CLLocation) async -> CurrentWeather? {
		switch await fetchWeatherWithError(for: location) {
			case .success(let weather):
			return weather
		case .failure:
			return nil
		}
	}
	
//	public func fetchDailyWeather(for location: CLLocation, from startDate: Date, to endDate: Date) async -> [DayWeather] {
//		switch await fetchDailyWeatherWithError(for: location, from: startDate, to: endDate) {
//		case .success(let weather):
//			return weather
//		case .failure:
//			return []
//		}
//	}
	
	public func fetchDailyWeather(for location: CLLocation, from startDate: Date, to endDate: Date) async ->  Result<[DayWeather],Error> {
		do {
			// Ottieni il meteo per la posizione
			let weather = try await weatherService.weather(for: location)
			
			// Filtra le previsioni per l'intervallo di date
			let filteredWeather = weather.dailyForecast.filter { dayWeather in
				let forecastDate = dayWeather.date
				return forecastDate >= startDate && forecastDate <= endDate
			}
			
			return .success(filteredWeather)
		} catch {
			return .failure(error)
		}
	}

}


public class WeatherManagerMock: WeatherRepository {
	//TODO: cover failure and success cases
	
	public init() {}
	
	public func fetchDailyWeather(for location: CLLocation, from startDate: Date, to endDate: Date) async -> Result<[DayWeather], Error> {
		return .success([
		])
	}
}
