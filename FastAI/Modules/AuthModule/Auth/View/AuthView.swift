//
//  AuthView.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    var body: some View {
        ZStack{
            Color.mainColor.ignoresSafeArea()
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 3){
                        Text("Fast AI")
                            .foregroundColor(.white)
                            .font(.system(size: 32).weight(.semibold))
                        Text("Based on YandexGPT")
                            .foregroundColor(.white)
                            .font(.system(size: 18).weight(.semibold))
                    }
                    Spacer()
                }
                Spacer()
                Image("ai_logo")
                    .resizable()
                    .scaledToFit()
                Spacer()
                VStack(spacing: 16){
                    TextField("Введите modelUri", text: $viewModel.modelUri)
                        .modifier(AuthTextField())
                    TextField("Введите apiKey", text: $viewModel.apiKey)
                        .modifier(AuthTextField())
                }
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondColor)
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Продолжить")
                            .foregroundColor(Color.mainColor)
                            .font(.system(size: 16).weight(.semibold))
                    }
                    .onTapGesture {
                        viewModel.login()
                    }
            }
            .padding(.horizontal, 22)
        }
    }
}

struct AuthTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 18).weight(.medium))
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondColor.opacity(0.5))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondColor, lineWidth: 2)
            }
    }
}

extension AuthView {
    func makeViewController() -> UIViewController {
        let hostingViewController = UIHostingController.init(rootView: self)
        return hostingViewController
    }
}
