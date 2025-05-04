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
    
    func getImages(messages: [String], completion: @escaping ([String]) -> Void) {
        let queue: DispatchQueue = .init(label: "com.queue.imageIds", attributes: .concurrent)
        let group = DispatchGroup()
        var ids: [String] = []
        
        for message in messages {
            group.enter()
            queue.async { [weak self] in
                self?.getImageId(messageText: message) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let success):
                        queue.async(flags: .barrier) {
                            ids.append(success.id)
                        }
                    case .failure(_):
                        queue.async(flags: .barrier) {
                            ids.append("")
                        }
                    }
                }
            }
        }
        group.notify(queue: queue) { [weak self] in
            let waitTime: Int = 12
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .init(waitTime)) {
                self?.getImagesByOperationIds(ids: ids, completion: completion)
            }
        }
    }
    
    private func getImagesByOperationIds(ids: [String], completion: @escaping ([String]) -> Void) {
        let queue: DispatchQueue = .init(label: "com.queue.images", attributes: .concurrent)
        let group = DispatchGroup()
        var imgCodes: [String] = []
        for id in ids {
            group.enter()
            queue.async { [weak self] in
                self?.getImageByOperationId(operationId: id) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let success):
                        queue.async(flags: .barrier) {
                            imgCodes.append(success.response?.image ?? "")
                        }
                    case .failure(_):
                        queue.async(flags: .barrier) {
                            imgCodes.append("")
                        }
                    }
                }
            }
        }
        group.notify(queue: queue) {
            completion(imgCodes)
        }
    }
    
    private func getImageId(messageText: String, completion: @escaping (Result<GPTImageGenerationIDResponseIdModel, NetworkError>) -> Void) {
        let apiKey: String? = userDataService.getApiKey()
        let modelUri: String? = userDataService.getModelUri()
        let endpoint = GPTEndpoint.getImageId(modelUri: modelUri, apiKey: apiKey, text: messageText)
        neworkService.request(endpoint, responseType: GPTImageGenerationIDResponseIdModel.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private func getImageByOperationId(operationId: String, completion: @escaping (Result<GPTImageGenerationResponseModel, NetworkError>) -> Void) {
        let apiKey: String? = userDataService.getApiKey()
        let endPoint = GPTEndpoint.getImageByOperation(apiKey: apiKey, id: operationId)
        neworkService.request(endPoint, responseType: GPTImageGenerationResponseModel.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
