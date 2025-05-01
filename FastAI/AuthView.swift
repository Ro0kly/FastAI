//
//  AuthView.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        ZStack{
            Color.mainColor.ignoresSafeArea()
            VStack {
                Text("Приветствую тебя ")
            }
        }
    }
}

extension AuthView {
    func makeViewController() -> UIViewController {
        let hostingViewController = UIHostingController.init(rootView: self)
        return hostingViewController
    }
}

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
}
