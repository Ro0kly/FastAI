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
        let isApiKeyExist = userDataService.getApiKey() != nil
        let isModelUriExit = userDataService.getModelUri() != nil
        if isApiKeyExist || isModelUriExit {
            showChat()
        } else {
            showAuth()
        }
    }
    
    func showAuth() {
        userDataService.clearUserData()
        let authVM = AuthViewModel(userDataService: userDataService)
        authVM.onLogingSuccess = { [weak self] in
            self?.showChat()
        }
        let authView = AuthView(viewModel: authVM)
        let authVC = authView.makeViewController()
        navigationController.setViewControllers([authVC], animated: true)
    }
    
    func showChat() {
        let networkService = NetworkService()
        let gptService = GPTService(neworkService: networkService, userDataService: userDataService)
        let chatViewModel = ChatViewModel(gptService: gptService)
        chatViewModel.onGoToImageGeneration = { [weak self] in
            self?.showImageGeneration()
        }
        chatViewModel.onLogout = { [weak self] in
            self?.showAuth()
        }
        let chatVC = ChatViewController(viewModel: chatViewModel)
        navigationController.setViewControllers([chatVC], animated: true)
    }
    
    func showImageGeneration() {
        let networkService = NetworkService()
        let gptService = GPTService(neworkService: networkService, userDataService: userDataService)
        let imageGenerationViewModel = ImageGenerationViewModel(gptService: gptService)
        imageGenerationViewModel.onGoToChat = { [weak self] in
            self?.showChat()
        }
        let imageGenerationVC = ImageGeneratonViewController(viewModel: imageGenerationViewModel)
        navigationController.setViewControllers([imageGenerationVC], animated: true)
    }
}
