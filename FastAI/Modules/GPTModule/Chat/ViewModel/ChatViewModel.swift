//
//  ChatViewModel.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

final class ChatViewModel {
    private let gptService: GPTService
    private(set) var messages: [MessageBlobModel] = []
    
    var onMessageUpdated: (() -> Void)?
    
    init(gptService: GPTService) {
        self.gptService = gptService
    }
    
    func showWelcomeMessage() {
        let message = MessageBlobModel.init(text: "Привет! Я твой AI-ассистент, и я готов отвечать на твои вопросы!", isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
    
    func sendMessage(_ text: String, requestFinished: @escaping () -> Void) {
        let message = MessageBlobModel.init(text: text, isUser: true)
        messages.append(message)
        onMessageUpdated?()
        
        gptService.sendMessage(messageText: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.processSuccessNetworkResponse(response)
                case .failure(let failure):
                    self?.processFailureNetworkResponse(failure)
                }
                requestFinished()
            }
        }
    }
    
    private func processSuccessNetworkResponse(_ response: GPTResponseModel) {
        guard let firstAlternative = response.result.alternatives.first else { return }
        let message = MessageBlobModel.init(text: firstAlternative.message.text, isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
    
    private func processFailureNetworkResponse(_ error: NetworkError) {
        let message = MessageBlobModel.init(text: error.description, isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
    
    private func processFailureKeychainResponse(_ text: String) {
        let message = MessageBlobModel.init(text: text, isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
}
