//
//  GPTService.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation

class GPTService {
    private let apiKey = ""
    private let modelUri = ""
    private let neworkService: NetworkService
    
    init(neworkService: NetworkService = .init()) {
        self.neworkService = neworkService
    }
    
    func sendMessage(messageText: String, completion: @escaping (Result<GPTResponseModel, NetworkError>) -> Void) {
        let endpoint = GPTEndpoint.askAssistant(modelUri: modelUri, apiKey: apiKey, text: messageText)
        neworkService.request(endpoint, responseType: GPTResponseModel.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
