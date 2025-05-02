//
//  ChatViewModel.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

class ChatViewModel {
    private let gptService: GPTService
    private(set) var messages: [MessageBlobModel] = []
    
    var onMessageUpdated: (() -> Void)?
    
    init() {
        self.gptService = .init()
    }
    
    func sendMessage(_ text: String, requestFinished: @escaping () -> Void) {
        let message = MessageBlobModel.init(text: text, isUser: true)
        messages.append(message)
        onMessageUpdated?()
        
        gptService.sendMessage(messageText: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.processSuccessResponse(response)
                case .failure(let failure):
                    self?.processFailureResponse(failure)
                }
                requestFinished()
            }
        }
    }
    
    private func processSuccessResponse(_ response: GPTResponseModel) {
        guard let firstAlternative = response.result.alternatives.first else { return }
        let message = MessageBlobModel.init(text: firstAlternative.message.text, isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
    
    private func processFailureResponse(_ error: NetworkError) {
        let message = MessageBlobModel.init(text: error.description, isUser: false)
        messages.append(message)
        onMessageUpdated?()
    }
}
