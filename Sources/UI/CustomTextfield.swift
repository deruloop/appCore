//
//  CustomTextfield.swift
//  PackdApp
//
//  Created by Cristiano Calicchia on 19/08/24.
//  Copyright © 2024 deruloop. All rights reserved.
//

import Foundation
import SwiftUI

///
///Source: https://fatbobman.medium.com/advanced-swiftui-textfield-events-focus-keyboard-c99bc9f57c91
///
public struct CustomTextfield: View {
	
	@Binding var text: String
	var placeholder: LocalizedStringKey
	@Binding var validators: [Validator]
	@Binding var errorState: Bool
	@Binding var toReload: Bool
	var design: Design
	var onCommit: (()->())
	var onFocusChanged: ((_ isFocused: Bool)->())
	var onSubmit: (()->())
	@FocusState private var isFocused: Bool
	
	@State var color: Color
	@State var userHasChangedTheInput: Bool = false
	
	public struct Design {
		var image: Image?
		var style: Style
		var selectedColor: Color
		var unselectedColor: Color
		var errorColor: Color
		var font: Font
		var errorFont: Font
		
		public init(
			style: Style,
			selectedColor: Color,
			unselectedColor: Color,
			errorColor: Color = .red,
			image: Image? = nil,
			font: Font,
			errorFont: Font) {
				self.image = image
				self.style = style
				self.selectedColor = selectedColor
				self.unselectedColor = unselectedColor
				self.errorColor = errorColor
				self.font = font
				self.errorFont = errorFont
		}
	}
	
	public init(
		text: Binding<String>,
		placeholder: LocalizedStringKey,
		design: Design,
		validators: Binding<[Validator]>,
		errorState: Binding<Bool>,
		toReload: Binding<Bool>,
		onCommit: @escaping ( () -> Void),
		onFocusChanged: @escaping ( (_: Bool) -> Void),
		onSubmit: @escaping ( () -> Void)) {
			self._text = text
			self.placeholder = placeholder
			self._errorState = errorState
			self._toReload = toReload
			self.onCommit = onCommit
			self.onFocusChanged = onFocusChanged
			self.onSubmit = onSubmit
			self._validators = validators
			self.design = design
			self.color = design.unselectedColor
	}
	
	public var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 0) {
				if let image = design.image {
					image
				}
				TextField(
					placeholder,
					text: $text,
					onCommit: {
						onCommit()
					})
				.setStyle(style: design.style, color: $color)
				.font(design.font)
				.onSubmit {
					onSubmit()
				}
				.focused($isFocused)
			}
			.onChange(of: text) { oldValue, newValue in
				evaluteChanges(for: newValue, isFocused: isFocused)
				userHasChangedTheInput = true
			}
			.onChange(of: toReload) { oldValue, newValue in
				evaluteChanges(for: text, isFocused: isFocused)
				userHasChangedTheInput = true
				toReload = false
			}
			.onChange(of: isFocused) { oldValue, newValue in
				if newValue {
					color = design.selectedColor
				} else {
					color = design.unselectedColor
					userHasChangedTheInput = true
				}
				if userHasChangedTheInput {
					evaluteChanges(for: text, isFocused: newValue)
				}
				onFocusChanged(newValue)
			}
			
			if userHasChangedTheInput {
				ForEach(getErrors(newValue: text), id: \.self) { error in
					Text(error)
						.font(design.errorFont)
						.multilineTextAlignment(.leading)
						.lineLimit(2)
						.foregroundColor(.red)
				}
			}
		}
	}
	
	func evaluteChanges(for value: String, isFocused: Bool) {
		let errors = getErrors(newValue: value)
		if !errors.isEmpty {
			color = design.errorColor
			errorState = true
		} else {
			if isFocused {
				color = design.selectedColor
			} else {
				color = design.unselectedColor
			}
			errorState = false
		}
	}
	
	func getErrors(newValue: String) -> [String] {
		let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)
		var errors: [String] = []
		for validator in validators {
			switch validator {
			case .unaccepetedValues(let values, let message):
				for value in values {
					if trimmedValue == value {
						errors.append(message)
						break
					}
				}
			case .notEmpty(message: let message):
				if trimmedValue.isEmpty {
					errors.append(message)
				}
			}
		}
		return errors
	}
	
	public enum Validator {
		case unaccepetedValues([String], message: String)
		case notEmpty(message: String)
	}
}

//MARK: Extensions
extension TextField {
	@ViewBuilder
	func setStyle(style: CustomTextfield.Style, color: Binding<Color>) -> some View {
		switch style {
		case .borded:
			self.textFieldStyle(BordedTextFieldStyle(color: color))
		}
	}
}

//MARK: Styles
public extension CustomTextfield {
	enum Style {
		case borded //BordedTextFieldStyle
	}
}

public struct BordedTextFieldStyle: @preconcurrency TextFieldStyle {
	@Binding var color: Color
	
	@MainActor public func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.padding(.vertical, 6)
			.border(width: 2, edges: [.bottom], color: color)
	}
}
