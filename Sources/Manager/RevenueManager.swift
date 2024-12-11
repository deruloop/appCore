//
//  RevenueManager.swift
//  AppCore
//
//  Created by Cristiano Calicchia on 10/12/24.
//

import Foundation
import RevenueCat
import RevenueCatUI
import SwiftUI

public class RevenueManager: ObservableObject {
	
	///If you want to debug RevenueCat status set this modifier on content and pass your state showing variable
	///.debugRevenueCatOverlay(isPresented: $displayPaywallDebug)
	
	private var offerings: Offerings? = nil
	
	public init(apiKey: String) {
		Purchases.logLevel = .debug
		Purchases.configure(withAPIKey: apiKey)
		Purchases.shared.getOfferings { (offerings, _) in
			self.offerings = offerings
		}
	}
	
	public func getPackagePriceWithIdentifier(_ identifier: String) -> String {
		if let package = offerings?.current?.package(identifier: identifier) {
			print(package.storeProduct)
			return package.storeProduct.localizedPriceString
		}
		return "Errore"
	}
	
	public func purchasePackageWithIdentifier(_ identifier: String) async -> Bool {
		if let package = offerings?.current?.package(identifier: identifier) {
			do {
				switch try await Purchases.shared.purchase(package: package) {
				case (let transaction, let customerInfo, let userCancelled):
					if userCancelled == false {
						return true
					} else {
						return false
					}
				}
			} catch {
				return false
			}
		}
		return false
	}
	
	public func isCustomerWithEntitlement(_ entitlement: String) async -> Result<Bool, Error> {
		do {
			let customerInfo = try await Purchases.shared.customerInfo()
			if customerInfo.entitlements[entitlement]?.isActive == true {
				// user has access to "pro" entitlement
				return .success(true)
			} else {
				return .success(false)
			}
		} catch {
			// return the error outside
			return .failure(error)
		}
	}

}
