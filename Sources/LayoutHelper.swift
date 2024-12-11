//
//  LayoutHelper.swift
//  PackdApp
//
//  Created by Cristiano Calicchia on 08/08/24.
//  Copyright © 2024 deruloop. All rights reserved.
//

import Foundation
import SwiftUI

final public class LayoutHelper: UIScreen {
	
	private static var foregroundWindow: UIWindow? {
		return UIApplication
			.shared
			.connectedScenes
			.compactMap { ($0 as? UIWindowScene)?.keyWindow }
			.last
	}
	
	public static let padding: CGFloat = isWidthLessThan414 ? 16 : 24
	public static let safeWidth: CGFloat = getBounds.width - padding * 2
	
	public static var hasNotch: Bool { main.bounds.height / main.bounds.width > 2 }
	public static var getSafeAreaTop: CGFloat { foregroundWindow?.safeAreaInsets.top ?? (hasNotch ? 44 : 20) }
	public static var getSafeAreaBottom: CGFloat { foregroundWindow?.safeAreaInsets.bottom ?? (hasNotch ? 34 : 0) }
	public static var getBounds: CGRect {
		
		let tmpHeight = UIScreen.main.bounds.height
		let tmpWidth = UIScreen.main.bounds.width
		let origin = UIScreen.main.bounds.origin
		
		return tmpWidth > tmpHeight
			? CGRect(origin: origin, size: CGSize(width: tmpHeight, height: tmpWidth))
			: UIScreen.main.bounds
		
	}
	public static var isPhoneSE: Bool { getBounds.width == 320 }
	public static var isIPhone8: Bool { getBounds.height == 667 }
	public static var isProMax: Bool { getBounds.height == 896 }
	public static var isWidthLessThan428: Bool { getBounds.width < 428 }
	public static var isWidthLessThan414: Bool { getBounds.width < 414 }
	public static var isWidthLessThan390: Bool { getBounds.width < 390 }
	public static var isForcedPortrait: Bool {
		
		let tmpHeight = UIScreen.main.bounds.height
		let tmpWidth = UIScreen.main.bounds.width
		
		return tmpWidth > tmpHeight
		
	}
	public static var pixelDensity: CGFloat { main.nativeScale }
	public static var cornerRadiusInfinity: CGFloat = 2000
	public static var defaultTextScaleFactor: CGFloat {
		
		if #available(iOS 14, *) { return 0.3 }
		return .leastNonzeroMagnitude
		
	}
	
	public static var isRunningOnMac: Bool {
		if #available(iOS 14.0, *) {
			return ProcessInfo.processInfo.isMacCatalystApp
		}
		return false
	}
	
}
