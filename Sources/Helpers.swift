//
//  Helpers.swift
//  PackdApp
//
//  Created by deruloop on 10.11.2019.
//
//

import SwiftUI
import Combine

// MARK: - General

public extension ProcessInfo {
    var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

//MARK: Localization
public extension String {
    func localized(_ locale: Locale) -> String {
        let localeId = String(locale.identifier.prefix(2))
        guard let path = Bundle.main.path(forResource: localeId, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}

//MARK: Array helpers
public extension Array {
	func chunked(into size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}

public extension Collection where Indices.Iterator.Element == Index {
	
	subscript (safe index: Index) -> Iterator.Element? {
		indices.contains(index) ? self[index] : nil
	}
	
}

public extension RangeReplaceableCollection where Element: Equatable {
	@discardableResult
	mutating func removeFirst(_ element: Element) -> Element? {
		guard let index = firstIndex(of: element) else { return nil }
		return remove(at: index)
	}
}

//MARK: Colors helper
public extension UIColor {

	func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
		return self.adjust(by: abs(percentage) )
	}

	func darker(by percentage: CGFloat = 30.0) -> UIColor? {
		return self.adjust(by: -1 * abs(percentage) )
	}

	func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
			return UIColor(red: min(red + percentage/100, 1.0),
						   green: min(green + percentage/100, 1.0),
						   blue: min(blue + percentage/100, 1.0),
						   alpha: alpha)
		} else {
			return nil
		}
	}
}

//MARK: use hex color
public extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0)
		}

		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue:  Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}

public extension Color {
	
#if os(macOS)
	public static let background = Color(NSColor.windowBackgroundColor)
	public static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
	static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
#else
	public static let background = Color(UIColor.systemBackground)
	public static let secondaryBackground = Color(UIColor.secondarySystemBackground)
	public static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
#endif
	
	public func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
		let color = UIColor(self)
		var currentHue: CGFloat = 0
		var currentSaturation: CGFloat = 0
		var currentBrigthness: CGFloat = 0
		var currentOpacity: CGFloat = 0

		if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
			return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrigthness + brightness, opacity: currentOpacity + opacity)
		}
		return self
	}
}

//MARK: Main app padding
public struct MainPaddingHorizontal: ViewModifier {
	public func body(content: Content) -> some View {
		content
			.padding(.horizontal, LayoutHelper.padding)
		
	}
}
public extension View {
	func mainPaddingHorizontal() -> some View {
		self.modifier(MainPaddingHorizontal())
	}
}

//MARK: Keyboard
public extension View {
	func keyboardDismissOnDrag() -> some View {
		modifier(KeyboardDismissOnDragGesture())
	}
}

public struct KeyboardDismissOnDragGesture: ViewModifier {
	public func body(content: Content) -> some View {
		content.simultaneousGesture(DragGesture().onChanged { _ in
			UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		})
	}
}

//Get keyboard shown hidden infos
public extension View {
	public var keyboardPublisher: AnyPublisher<Bool, Never> {
	Publishers
	  .Merge(
		NotificationCenter
		  .default
		  .publisher(for: UIResponder.keyboardWillShowNotification)
		  .map { _ in true },
		NotificationCenter
		  .default
		  .publisher(for: UIResponder.keyboardWillHideNotification)
		  .map { _ in false })
	  .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
	  .eraseToAnyPublisher()
  }
}

//Get keyboard height infos
public extension Publishers {
	static var keyboardHeight: AnyPublisher<CGFloat, Never> {
		let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
			.map { $0.keyboardHeight }
		
		let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
			.map { _ in CGFloat(0) }
		
		return MergeMany(willShow, willHide)
			.eraseToAnyPublisher()
	}
}

public extension Notification {
	var keyboardHeight: CGFloat {
		return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
	}
}

//MARK: Date
public extension Date {
	func toString(_ format: AppDateFormat) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format.rawValue
		formatter.locale = Locale(identifier: "it_IT")
		return formatter.string(from: self)
	}
}

public enum AppDateFormat: String {
	// Format: dd.MM.yyyy (e.g., 06.09.2023)
	case ddMMyyyy = "dd.MM.yyyy"
	
	// Format: dd-MM-yyyy (e.g., 06-09-2023)
	case ddMMyyyyWithDashes = "dd-MM-yyyy"
	
	// Format: yyyy-MM-dd'T'HH:mm:ss.SSSZ (e.g., 2023-09-06T12:30:45.123+0200)
	case iso = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	
	// Format: yyyy-MM-dd'T'HH:mm:ssZ (e.g., 2023-09-06T12:30:45+0200)
	case customISO = "yyyy-MM-dd'T'HH:mm:ssZ"
	
	// Format: yyyy-MM-dd HH:mm (e.g., 2023-09-06 12:30)
	case ddMMMyyyyhhmm = "yyyy-MM-dd HH:mm"
	
	// Format: dd MMM YYYY (e.g., 06 Sep 2023)
	case ddMMMyyyy = "dd MMM YYYY"
	
	// Format: yyyy-MM-dd (e.g., 2023-09-06)
	case yyyyMMddWithDashes = "yyyy-MM-dd"
	
	// Format: dd/MM/yyyy (e.g., 06/09/2023)
	case ddMMyyyyWithSlash = "dd/MM/yyyy"
	
	// Format: dd/MM (e.g., 06/09)
	case ddMMWithSlash = "dd/MM"
	
	// Format: dd/MM/yyyy (e.g., 06/09/2023)
	case ddMMyyyyWithSlashAndHhMm = "dd/MM/yyyy HH:mm"
	
	// Format: dd (e.g., 06)
	case dd = "dd"
	
	// Format: MMMM yyyy (e.g., September 2023)
	case MMMMyyyy = "MMMM yyyy"
	
	// Format: MMM yy (e.g., Sep 23)
	case MMMyy = "MMM yy"
	
	// Format: HH:mm (e.g., 12:30)
	case HHmm = "HH:mm"
	
	// Format: HH:mm:ss (e.g., 12:30:00)
	case HHmmss = "HH:mm:ss"
	
	// Format: yyyy-MM-dd'T'HH:mm:ss.SSS'+'0000' (e.g., 2023-09-06T12:30:45.123+0000)
	case pmed = "yyyy-MM-dd'T'HH:mm:ss.SSS'+'0000"
	
	// Format: dd-MM-yyyy HH:mm:ss.SSS (e.g., 06-09-2023 12:30:45.123)
	case notificator = "dd-MM-yyyy HH:mm:ss.SSS"
	
	// Format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z' (e.g., 2023-09-06T12:30:45.123Z)
	case isoCjOutput = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
}


//MARK: Single Edge Border modifier
public struct EdgeBorder: Shape {
	var width: CGFloat
	var edges: [Edge]

	public func path(in rect: CGRect) -> Path {
		edges.map { edge -> Path in
			switch edge {
			case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
			case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
			case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
			case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
			}
		}.reduce(into: Path()) { $0.addPath($1) }
	}
}

public extension View {
	func border(width: CGFloat, edges: [Edge], color: any ShapeStyle) -> some View {
		overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color as? Color))
	}
}

