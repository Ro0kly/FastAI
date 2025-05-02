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
