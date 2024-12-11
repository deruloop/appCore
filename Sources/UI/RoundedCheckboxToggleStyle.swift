//
//  RoundedCheckboxToggleStyle.swift
//
//  Created by Cristiano Calicchia on 28/08/24.
//  Copyright © 2024 deruloop. All rights reserved.
//

import Foundation
import SwiftUI

public struct RoundedCheckboxToggleStyle: ToggleStyle {
	var color: Color
	var imageSize: Font
	
	public init(color: Color, imageSize: Font) {
		self.color = color
		self.imageSize = imageSize
	}
	
	public func makeBody(configuration: Configuration) -> some View {
		HStack {

			RoundedRectangle(cornerRadius: 2.0)
				.border(color, width: 2)
				.foregroundStyle(configuration.isOn ? color : .background)
				.frame(width: 16, height: 16)
				.cornerRadius(2.0)
				.overlay {
					if configuration.isOn {
						Image("check")
							.font(imageSize)
							.foregroundStyle(.white)
					}
				}
				.onTapGesture {
//					withAnimation(.spring()) {
						configuration.isOn.toggle()
//					}
				}

			configuration.label

		}
	}
}
