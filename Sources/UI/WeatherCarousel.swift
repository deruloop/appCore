//
//  WeatherCarousel.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 23/01/25.
//

import SwiftUI
import WeatherKit

public struct WeatherCarousel: View {
	var dto: [WeatherCarouselDto]
	var design: Design
	
	public struct Design {
		let font: Font
		let textColor: Color
		let backgroundColor: Color
		
		public init(font: Font, textColor: Color, backgroundColor: Color) {
			self.font = font
			self.textColor = textColor
			self.backgroundColor = backgroundColor
		}
	}
	
	public init(dto: [WeatherCarouselDto], design: Design) {
		self.dto = dto
		self.design = design
	}
	
	public var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 0) {
				ForEach(dto, id: \.self) { dayWeather in
					WeatherCellView(
						dayWeather: dayWeather,
						design: design
					)
				}
			}
		}
	}
	
}

extension WeatherCarousel{
	struct WeatherCellView: View {
		@State private var isExpanded: Bool = false
		var dayWeather: WeatherCarouselDto
		var design: Design

		public var body: some View {
			HStack(spacing: 0) {
				// First button
				VStack {
					Text(dayWeather.emoji)
						.font(.system(size: 20))
					Text(dayWeather.conditionDescription)
						.bold()
						.lineLimit(2)
						.minimumScaleFactor(0.8)
					Text(dayWeather.date)
				}
				.font(design.font)
				.foregroundColor(.white)
				.padding(.horizontal, 8)
				.frame(width: 120, height: 80)
				.background(design.backgroundColor)
				.cornerRadius(8)
				.onTapGesture {
					withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
						isExpanded.toggle()
					}
				}

				if isExpanded {
					VStack {
						HStack(spacing: 2) {
							Text("🌡️")
							Text(dayWeather.highTemperature)
								.bold()
								.foregroundStyle(Color(hex: "#ff5900"))
							Text(dayWeather.lowTemperature)
								.padding(.leading, 3)
								.bold()
								.foregroundStyle(Color(hex: "#028bed"))
						}
						HStack(spacing: 2) {
							Text("💨")
							Text(dayWeather.windInfo)
						}
						HStack(spacing: 2) {
							Text("☔️")
							Text(dayWeather.precipitationChance)
								.bold()
								.foregroundStyle(Color(hex: "#0495b5"))
						}
					}
					.foregroundStyle(design.textColor)
					.font(design.font)
					.frame(height: 80)
					.padding(.leading, 4)
					.padding(.horizontal, 8)
					.background(Color(hex: "#DFDFDF"))
					.cornerRadius(8)
					.zIndex(-1)
					.offset(x: -10)
					.transition(.asymmetric(
						insertion: .move(edge: .leading).combined(with: .opacity),
						removal: .move(edge: .leading).combined(with: .opacity)
					))
					.onTapGesture {
						withAnimation(.spring(response: 0.1, dampingFraction: 0.8)) {
							isExpanded.toggle()
						}
					}
				}
			}
			.padding(.trailing, isExpanded ? 0 : 10)
		}
	}
}

public extension WeatherCarousel {
	struct WeatherCarouselDto: Hashable {
		let emoji: String
		let date: String
		let highTemperature: String
		let lowTemperature: String
		let conditionDescription: String
		let windInfo: String
		let precipitationChance: String
		
		// Initialize with a DayWeather object
		public init(dayWeather: DayWeather) {
			// Date formatting
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			self.date = dayWeather.date.toString(.ddMMWithSlash)
			
			// Temperature formatting
			let measurementFormatter = MeasurementFormatter()
			measurementFormatter.unitOptions = .providedUnit
			self.highTemperature = measurementFormatter.string(from: dayWeather.highTemperature.converted(to: .celsius).rounded(toPlaces: 0))
			self.lowTemperature = measurementFormatter.string(from: dayWeather.lowTemperature.converted(to: .celsius).rounded(toPlaces: 0))
			
			// Condition description
			self.conditionDescription = dayWeather.condition.description
			
			self.emoji = dayWeather.condition.emoji()
			
			// Wind information
			let windSpeed = measurementFormatter.string(from: dayWeather.wind.speed.converted(to: .kilometersPerHour).rounded(toPlaces: 1))
			let windDirection = dayWeather.wind.direction.converted(to: .degrees).value
			self.windInfo = "\(windSpeed), \(Int(windDirection))°"
			
			// Precipitation chance
			self.precipitationChance = "\(Int(dayWeather.precipitationChance * 100))%"
		}
		
		// Initializer for mock or custom data (testing, prototyping)
		init(
			emoji: String,
			date: Date,
			highTemperature: Double,
			lowTemperature: Double,
			conditionDescription: String,
			windSpeed: Double,
			windDirection: Double,
			precipitationChance: Double
		) {
			self.date = date.toString(.ddMMWithSlash)
			self.emoji = emoji
			
			let measurementFormatter: Foundation.MeasurementFormatter = MeasurementFormatter()
			let highTempMeasurement = Measurement(value: highTemperature, unit: UnitTemperature.celsius)
			self.highTemperature = measurementFormatter.string(from: highTempMeasurement)
			
			let lowTempMeasurement = Measurement(value: lowTemperature, unit: UnitTemperature.celsius)
			self.lowTemperature = measurementFormatter.string(from: lowTempMeasurement)
			
			self.conditionDescription = conditionDescription
			
			let windSpeedMeasurement = Measurement(value: windSpeed, unit: UnitSpeed.kilometersPerHour)
			self.windInfo = "\(measurementFormatter.string(from: windSpeedMeasurement)), \(Int(windDirection))°"
			
			self.precipitationChance = "\(Int(precipitationChance * 100))%"
		}
	}
}

#Preview {
	WeatherCarousel(
		dto: [
			WeatherCarousel.WeatherCarouselDto(emoji: "☀️",
											   date: Date(),
											   highTemperature: 22.0,
											   lowTemperature: 15.0,
											   conditionDescription: "Sunny",
											   windSpeed: 10.0,
											   windDirection: 180.0,
											   precipitationChance: 0.25),
			WeatherCarousel.WeatherCarouselDto(emoji: "☀️",
											   date: Date(),
											   highTemperature: 22.0,
											   lowTemperature: 15.0,
											   conditionDescription: "Sunny",
											   windSpeed: 10.0,
											   windDirection: 180.0,
											   precipitationChance: 0.25)
		],
		design: .init(font: .system(size: 15), textColor: Color.black, backgroundColor: Color.gray)
	)
	.padding(.horizontal)
}

extension WeatherCondition {
	// Function to get the corresponding emoji for the WeatherCondition
	func emoji() -> String {
		switch self {
		// Clear and sunny conditions
		case .clear, .mostlyClear:
			return "☀️"
		case .partlyCloudy, .mostlyCloudy:
			return "⛅️"
		case .cloudy:
			return "☁️"

		// Rain-related conditions
		case .drizzle, .freezingDrizzle, .rain, .sunShowers:
			return "🌧️"
		case .heavyRain:
			return "🌦️"
		case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms:
			return "⛈️"

		// Snow and wintry conditions
		case .snow, .flurries, .sunFlurries, .heavySnow, .blowingSnow:
			return "❄️"
		case .wintryMix, .sleet:
			return "🌨️"

		// Extreme conditions
		case .blizzard, .frigid:
			return "🥶"
		case .hurricane, .tropicalStorm:
			return "🌀"
		case .strongStorms:
			return "🌪️"

		// Other conditions
		case .foggy, .haze:
			return "🌫️"
		case .breezy, .windy:
			return "💨"
		case .blowingDust, .smoky:
			return "🌪️"
		case .hot:
			return "🔥"
		case .hail:
			return "🌨️"
		case .freezingRain:
			return "🌧️"
			
		@unknown default:
			return "❓"
		}
	}
}
