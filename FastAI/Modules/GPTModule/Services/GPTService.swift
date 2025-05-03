//
//  GPTService.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation

final class GPTService {
    private let neworkService: NetworkService
    private let userDataService: UserDataService
    
    init(neworkService: NetworkService, userDataService: UserDataService) {
        self.neworkService = neworkService
        self.userDataService = userDataService
    }
    
    func sendMessage(messageText: String, completion: @escaping (Result<GPTResponseModel, NetworkError>) -> Void) {
        let apiKey: String? = userDataService.getApiKey()
        let modelUri: String? = userDataService.getModelUri()
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
