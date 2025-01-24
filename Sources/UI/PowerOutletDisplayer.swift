//
//  PowerOutletDisplayer.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 24/01/25.
//

import Foundation
import SwiftUI
import CoreLocation

public struct PowerOutletDisplayer: View {
	var powerOutlets: [PowerOutlet]
	var font: Font
	var primaryColor: Color
	var secondaryColor: Color
	
	public init(countryCode: String, font: Font, primaryColor: Color, secondaryColor: Color) {
		self.font = font
		self.primaryColor = primaryColor
		self.secondaryColor = secondaryColor
		self.powerOutlets = PowerOutletManager.shared.getPowerOutlets(for: countryCode)
	}
	
	public var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(powerOutlets, id: \.self) { powerOutlet in
					VStack {
						Image(systemName: powerOutlet.systemImageName)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 40)
							.foregroundStyle(primaryColor, secondaryColor)
						Text(powerOutlet.type)
							.font(font)
					}
				}
			}
		}
	}
}

struct PowerOutlet: Hashable {
	let type: String // Example: "Type A"
	let systemImageName: String // Example: "poweroutlet.type.a.square"
}

class PowerOutletManager {
	static let shared = PowerOutletManager() // Shared instance
		
	private init() {} // Prevent external initialization
	
	// Dictionary mapping country codes (ISO 3166-1 alpha-2) to power outlet types
	private let powerOutletMapping: [String: [PowerOutlet]] = [
		// North America
		"US": [PowerOutlet(type: "Type A", systemImageName: "poweroutlet.type.a.square"),
			   PowerOutlet(type: "Type B", systemImageName: "poweroutlet.type.b.square")],
		"CA": [PowerOutlet(type: "Type A", systemImageName: "poweroutlet.type.a.square"),
			   PowerOutlet(type: "Type B", systemImageName: "poweroutlet.type.b.square")],
		"MX": [PowerOutlet(type: "Type A", systemImageName: "poweroutlet.type.a.square"),
			   PowerOutlet(type: "Type B", systemImageName: "poweroutlet.type.b.square")],

		// Europe
		"EU": [PowerOutlet(type: "Type C", systemImageName: "poweroutlet.type.c.square"),
			   PowerOutlet(type: "Type E", systemImageName: "poweroutlet.type.e.square"),
			   PowerOutlet(type: "Type F", systemImageName: "poweroutlet.type.f.square")],
		"IT": [PowerOutlet(type: "Type C", systemImageName: "poweroutlet.type.c.square"),
			   PowerOutlet(type: "Type L", systemImageName: "poweroutlet.type.l.square")],
		"UK": [PowerOutlet(type: "Type G", systemImageName: "poweroutlet.type.g.square")],

		// Asia
		"JP": [PowerOutlet(type: "Type A", systemImageName: "poweroutlet.type.a.square"),
			   PowerOutlet(type: "Type B", systemImageName: "poweroutlet.type.b.square")],
		"CN": [PowerOutlet(type: "Type I", systemImageName: "poweroutlet.type.i.square"),
			   PowerOutlet(type: "Type A", systemImageName: "poweroutlet.type.a.square"),
			   PowerOutlet(type: "Type C", systemImageName: "poweroutlet.type.c.square")],

		// Oceania
		"AU": [PowerOutlet(type: "Type I", systemImageName: "poweroutlet.type.i.square")],
		"NZ": [PowerOutlet(type: "Type I", systemImageName: "poweroutlet.type.i.square")],

		// South America
		"BR": [PowerOutlet(type: "Type N", systemImageName: "poweroutlet.type.n.square"),
			   PowerOutlet(type: "Type C", systemImageName: "poweroutlet.type.c.square")],

		// Africa
		"ZA": [PowerOutlet(type: "Type D", systemImageName: "poweroutlet.type.d.square"),
			   PowerOutlet(type: "Type M", systemImageName: "poweroutlet.type.m.square")]
	]

	/// Returns the power outlets for a given country code
	func getPowerOutlets(for countryCode: String) -> [PowerOutlet] {
		return powerOutletMapping[countryCode.uppercased()] ?? []
	}
}


#Preview {
	PowerOutletDisplayer(countryCode: "EU", font: .system(size: 15), primaryColor: Color.black, secondaryColor: Color.blue)
	
}
