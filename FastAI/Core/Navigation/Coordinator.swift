//
//  Coordinator.swift
//  FastAI
//
//  Created by Rookly on 03.05.2025.
//

import Foundation
import UIKit

final class Coordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let userDataService: UserDataService
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = .init()
        self.userDataService = .init(keychainService: .shared)
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let isApiKeyExist = KeychainService.shared.get(forKey: AuthConstants.modelUri.description) != nil
        let isModelUriExit = KeychainService.shared.get(forKey: AuthConstants.apiKey.description) != nil
        print("api key:", isApiKeyExist)
        if isApiKeyExist && isModelUriExit {
            showChat()
        } else {
            showAuth()
        }
    }
    
    func showAuth() {
        let authVM = AuthViewModel(userDataService: userDataService)
        authVM.onLogingSuccess = { [weak self] in
            self?.showChat()
        }
        let authView = AuthView(viewModel: authVM)
        let authVC = authView.makeViewController()
        navigationController.pushViewController(authVC, animated: false)
    }
    
    func showChat() {
        let networkService = NetworkService()
        let gptService = GPTService(neworkService: networkService, userDataService: userDataService)
        let chatViewModel = ChatViewModel(gptService: gptService)
        let chatVC = ChatViewController(viewModel: chatViewModel)
        navigationController.pushViewController(chatVC, animated: true)
    }
}
