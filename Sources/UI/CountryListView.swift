//
//  File.swift
//  PackdApp
//
//  Created by Cristiano Calicchia on 04/09/24.
//  Copyright © 2024 deruloop. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

public struct PlaceElement: Equatable,Hashable {
	public let latitude: Double
	public let longitude: Double
	public let title: String
	public let subtitle: String
	
	public init(latitude: Double, longitude: Double, title: String, subtitle: String) {
		self.latitude = latitude
		self.longitude = longitude
		self.title = title
		self.subtitle = subtitle
	}
	
	@MainActor public static let mock: PlaceElement = .init(latitude: 0.0, longitude: 0.0, title: "TestPlace", subtitle: "TestPlaceSubtitle")
}

public struct PlaceListView: View {
	@Binding var selectedPlace: PlaceElement?
	@Binding var text: String
	@State var isLoading: Bool = false
	@State var cities: [PlaceElement] = []
	@Binding var errorHandler: ErrorType
	
	@StateObject var viewModel: SearchCompleterViewModel = SearchCompleterViewModel()
	
	public init(selectedPlace: Binding<PlaceElement?>, text: Binding<String>, isLoading: Bool = false, cities: [PlaceElement] = [], errorHandler: Binding<ErrorType>) {
		self._selectedPlace = selectedPlace
		self._text = text
		self.isLoading = isLoading
		self.cities = cities
		self._errorHandler = errorHandler
	}
	
	public var body: some View {
		
		LazyVStack {
			if !text.isEmpty {
				//Evolutive viewModel.searchResults.prefix(5) to get only first x elements
				ForEach(viewModel.searchResults, id: \.self) { city in
					Button {
						// Perform search for the selected location to get coordinates
						viewModel.searchForLocation(completion: city) { (coordinate, error) in
							switch error {
							case .none:
								if let coordinate = coordinate {
									selectedPlace = PlaceElement(
										latitude: coordinate.latitude,
										longitude: coordinate.longitude,
										title: city.title,
										subtitle: city.subtitle)
									text = city.title
								} else {
									errorHandler = .locationNoCoordinatesError(error: "Could not find coordinates for \(city.title).")
								}
							default :
								errorHandler = error
							}
						}
					} label: {
						VStack(alignment: .leading) {
							Text(city.title)
								.font(.headline)
							Text(city.subtitle)
								.font(.subheadline)
								.foregroundColor(.gray)
							
							Divider()
						}
					}
				}
			}
		}
		.onChange(of: text) { oldValue, newValue in
			viewModel.searchQuery = newValue
		}
		.onChange(of: viewModel.internetConnectionError) { oldValue, newValue in
			if newValue == true {
				errorHandler = .noInternetConnectionError
				viewModel.internetConnectionError = false
			}
		}
		
	}
}



public class SearchCompleterViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
	@Published var searchResults: [MKLocalSearchCompletion] = []
	@Published var searchQuery: String = "" {
		didSet {
			completer.queryFragment = searchQuery
		}
	}
	@Published var internetConnectionError: Bool = false
	
	private var completer: MKLocalSearchCompleter
	
	public override init() {
		completer = MKLocalSearchCompleter()
		super.init()
		completer.delegate = self
		completer.resultTypes = .address
	}
	
	public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		// Filter results to get only cities
		searchResults = completer.results
	}
	
	public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		internetConnectionError = true
	}
	
	// Function to perform MKLocalSearch and get coordinates from MKLocalSearchCompletion
	@MainActor
	func searchForLocation(completion: MKLocalSearchCompletion, completionHandler: @escaping (CLLocationCoordinate2D?, PlaceListView.ErrorType) -> Void) {
		let searchRequest = MKLocalSearch.Request()
		searchRequest.naturalLanguageQuery = completion.title + " " + completion.subtitle
		
		// Optionally, you can set the region for better accuracy
		// searchRequest.region = someMKCoordinateRegion
		
		let localSearch = MKLocalSearch(request: searchRequest)
		localSearch.start { response, error in
			guard error == nil else {
				completionHandler(nil, .locationSearchError(error: error?.localizedDescription ?? ""))
				return
			}
			
			// Extract the first matching map item, which contains the coordinates
			if let mapItem = response?.mapItems.first {
				completionHandler(mapItem.placemark.coordinate, .none)
			} else {
				completionHandler(nil, .locationMatchMapItemError(error: error?.localizedDescription ?? ""))
			}
		}
	}
}

public extension PlaceListView {
	enum ErrorType: Equatable {
		case none
		case locationSearchError(error: String)
		case locationMatchMapItemError(error: String)
		case locationNoCoordinatesError(error: String)
		case noInternetConnectionError
	}
}
