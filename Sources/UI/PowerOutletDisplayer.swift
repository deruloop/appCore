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

	/// Whether outlet data exists for the given ISO 3166-1 alpha-2 country code.
	/// Callers use this to show a graceful fallback instead of an empty view.
	public static func hasOutlets(for countryCode: String) -> Bool {
		!PowerOutletManager.shared.getPowerOutlets(for: countryCode).isEmpty
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

	/// Builds an outlet from a single IEC plug-type letter (A–O).
	init(letter: Character) {
		let upper = String(letter).uppercased()
		self.type = "Type \(upper)"
		self.systemImageName = "poweroutlet.type.\(upper.lowercased()).square"
	}
}

final class PowerOutletManager {
	static let shared = PowerOutletManager() // Shared instance

	private init() {} // Prevent external initialization

	// ISO 3166-1 alpha-2 country code -> IEC plug-type letters used there.
	// Symbols exist for types A–O (verified against SF Symbols). Source: worldstandards.eu.
	private let plugLettersByCountry: [String: String] = [
		// Europe
		"AD": "CF", "AL": "CF", "AT": "CF", "AX": "CF", "BA": "CF", "BE": "CE",
		"BG": "CF", "BY": "CF", "CH": "CJ", "CY": "G", "CZ": "CE", "DE": "CF",
		"DK": "CEFK", "EE": "CF", "ES": "CF", "FI": "CF", "FO": "CEFK", "FR": "CE",
		"GB": "G", "GE": "CF", "GG": "CG", "GI": "CG", "GL": "CEFK", "GR": "CF",
		"HR": "CF", "HU": "CF", "IE": "G", "IM": "CG", "IS": "CF", "IT": "CFL",
		"JE": "CG", "LI": "CJ", "LT": "CF", "LU": "CF", "LV": "CF", "MC": "CDEF",
		"MD": "CF", "ME": "CF", "MK": "CF", "MT": "G", "NL": "CF", "NO": "CF",
		"PL": "CE", "PT": "CF", "RO": "CF", "RS": "CF", "RU": "CF", "SE": "CF",
		"SI": "CF", "SK": "CE", "SM": "CFL", "UA": "CF", "VA": "CFL", "XK": "CF",

		// North & Central America, Caribbean
		"AG": "AB", "AI": "AB", "AW": "ABF", "BB": "AB", "BM": "AB", "BS": "AB",
		"BZ": "ABG", "CA": "AB", "CR": "AB", "CU": "ABCL", "DM": "DG", "DO": "AB",
		"GD": "G", "GP": "CE", "GT": "AB", "GU": "AB", "HN": "AB", "HT": "AB",
		"JM": "AB", "KN": "ABDG", "KY": "AB", "LC": "G", "MQ": "CDE",
		"MS": "AB", "MX": "AB", "NI": "AB", "PA": "AB", "PM": "CE", "PR": "AB",
		"SV": "AB", "TC": "AB", "TT": "AB", "US": "AB", "VC": "G", "VG": "AB", "VI": "AB",

		// South America
		"AR": "CI", "BO": "AC", "BR": "CN", "CL": "CL", "CO": "AB", "EC": "AB",
		"FK": "G", "GF": "CDE", "GY": "ABDG", "PE": "ABC", "PY": "C", "SR": "ABCF",
		"UY": "CFIL", "VE": "AB",

		// Asia
		"AE": "CDG", "AF": "CDF", "AM": "CF", "AZ": "CF", "BD": "ACDGK", "BH": "G",
		"BN": "G", "BT": "CDFG", "CN": "ACI", "HK": "G", "ID": "CF", "IL": "CHM",
		"IN": "CDM", "IQ": "CDG", "IR": "CF", "JO": "BCDFGJ", "JP": "AB", "KG": "CF",
		"KH": "ACG", "KP": "ACF", "KR": "CF", "KW": "CG", "KZ": "CF", "LA": "ABCEF",
		"LB": "ABCDG", "LK": "DGM", "MM": "CDFG", "MN": "CE", "MO": "DFGM", "MV": "DG",
		"MY": "G", "NP": "CDM", "OM": "CG", "PH": "ABC", "PK": "CDGM", "PS": "CHM",
		"QA": "DG", "SA": "ABFG", "SG": "G", "SY": "CEL", "TH": "ABCFO", "TJ": "CFI",
		"TL": "CEFI", "TM": "BCF", "TR": "CF", "TW": "AB", "UZ": "CFI", "VN": "ACF",
		"YE": "ADG",

		// Africa
		"AO": "C", "BF": "CE", "BI": "CE", "BJ": "CE", "BW": "DGM", "CD": "CDE",
		"CF": "CE", "CG": "CE", "CI": "CE", "CM": "CE", "CV": "CF", "DJ": "CE",
		"DZ": "CF", "EG": "CF", "ER": "CL", "ET": "CEFL", "GA": "C", "GH": "DG",
		"GM": "G", "GN": "CFK", "GQ": "CE", "GW": "C", "KE": "G", "KM": "CE",
		"LR": "ABCEF", "LS": "M", "LY": "CDF", "MA": "CE", "MG": "CDEJK", "ML": "CE",
		"MR": "C", "MU": "CG", "MW": "G", "MZ": "CFM", "NA": "DM", "NE": "CEF",
		"NG": "DG", "RE": "CE", "RW": "CJ", "SC": "G", "SD": "CD", "SH": "G",
		"SL": "DG", "SN": "CDEK", "SO": "C", "SS": "CD", "ST": "CF", "SZ": "M",
		"TD": "CDEF", "TG": "C", "TN": "CE", "TZ": "DG", "UG": "G", "YT": "CE",
		"ZA": "CDMN", "ZM": "CDG", "ZW": "DG",

		// Oceania
		"AS": "ABFI", "AU": "I", "CK": "I", "FJ": "I", "FM": "AB", "KI": "I",
		"MH": "AB", "NC": "CF", "NR": "I", "NU": "I", "NZ": "I", "PF": "ABCE",
		"PG": "I", "PW": "AB", "SB": "GI", "TK": "I", "TO": "I", "TV": "I",
		"VU": "I", "WF": "CE", "WS": "I",

		// Regional fallback (not returned by geocoders, kept for previews)
		"EU": "CEF"
	]

	/// Returns the power outlets for a given country code (empty if unknown).
	func getPowerOutlets(for countryCode: String) -> [PowerOutlet] {
		guard let letters = plugLettersByCountry[countryCode.uppercased()], !letters.isEmpty else {
			return []
		}
		return letters.map { PowerOutlet(letter: $0) }
	}
}


#Preview {
	PowerOutletDisplayer(countryCode: "EU", font: .system(size: 15), primaryColor: Color.black, secondaryColor: Color.blue)

}
