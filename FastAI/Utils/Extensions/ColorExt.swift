//
//  ColorExt.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    static let mainColor = Color.init(hex: 0x1D2633)
    static let secondColor = Color.init(hex: 0x17D7C7)
}
