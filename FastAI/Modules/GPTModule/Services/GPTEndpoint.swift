//
//  GPTEndpoint.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

enum GPTEndpoint: Endpoint {
    case askAssistant(modelUri: String?, apiKey: String?, text: String)
    case getImageId(modelUri: String?, apiKey: String?, text: String)
    case getImageByOperation(apiKey: String?, id: String)
}

extension GPTEndpoint {
    var baseURL: String {
        switch self {
        case .askAssistant:
            "https://llm.api.cloud.yandex.net/foundationModels/v1"
        case .getImageId:
            "https://llm.api.cloud.yandex.net/foundationModels/v1"
        case .getImageByOperation(_, let id):
            "https://llm.api.cloud.yandex.net/operations/\(id)"
        }
    }
    
    var path: String {
        switch self {
        case .askAssistant: return "/completion"
        case .getImageId: return "/imageGenerationAsync"
        case .getImageByOperation: return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .askAssistant: return .post
        case .getImageId: return .post
        case .getImageByOperation: return .get
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .askAssistant(_, let apiKey, _), .getImageId(_, let apiKey, _), .getImageByOperation(let apiKey, _):
            return [
                "Authorization": "Bearer \(apiKey ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .askAssistant(let modelUri, _, let text):
            let requestBody = GPTRequestModel.init(modelUri: "gpt://\(modelUri ?? "")/yandexgpt-lite/rc",
                                                   completionOptions: .init(maxTokens: 500, temperature: 0.3),
                                                   messages: [
                                                    .init(role: "system", text: "0"),
                                                    .init(role: "user", text: text)
                                                   ])
            return try? JSONEncoder().encode(requestBody)
        case .getImageId(let modelUri, _, let text):
            let requestBody = GPTImageGenerationIDRequestModel.init(modelUri: "art://\(modelUri ?? "")/yandex-art/latest",
                                                                  messages: [
                                                                    .init(text: text, weigth: 1)
                                                                  ],
                                                                  generationOptions: .init(
                                                                    mimeType: "image/png",
                                                                    seed: "\(Int64.random(in: 0...1_000_000))",
                                                                    ratio: .init(widthRatio: 2, heightRation: 3)))
            return try? JSONEncoder().encode(requestBody)
        case .getImageByOperation(_, _):
            return nil
        }
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
