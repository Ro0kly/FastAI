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
    
    func sendMessage(messageText: String) async throws -> GPTResponseModel {
        guard let url = URL(string: "https://llm.api.cloud.yandex.net/foundationModels/v1/completion") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GPTRequestModel.init(modelUri: modelUri,
                                                completionOptions: .init(maxTokens: 500, temperature: 0.3),
                                                messages: [
                                                    .init(role: "system", text: "0"),
                                                    .init(role: "user", text: messageText)
                                                ])
        let body = try JSONEncoder().encode(requestBody)
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GPTResponseModel.self, from: data)
    }
    
//    func sendMessage(messageText: String, completion: @escaping (Result<GPTResponseModel, Error>) -> Void) {
//        let url = URL(string: "https://llm.api.cloud.yandex.net/foundationModels/v1/completion")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody = GPTRequestModel.init(modelUri: modelUri,
//                                                completionOptions: .init(maxTokens: 500, temperature: 0.3),
//                                                messages: [
//                                                    .init(role: "system", text: "0"),
//                                                    .init(role: "user", text: messageText)
//                                                ])
//
//        do {
//            let body = try JSONEncoder().encode(requestBody)
//            request.httpBody = body
//        } catch let err {
//            completion(.failure(err))
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                guard let data = data else {
//                    return
//                }
//
//                do {
//                    let response = try JSONDecoder().decode(GPTResponseModel.self, from: data)
//                    completion(.success(response))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }.resume()
//    }
}
