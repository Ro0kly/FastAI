//
//  GPTEndpoint.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

enum GPTEndpoint: Endpoint {
    case askAssistant(modelUri: String?, apiKey: String?, text: String)
}

extension GPTEndpoint {
    var baseURL: String { "https://llm.api.cloud.yandex.net/foundationModels/v1" }
    
    var path: String {
        switch self {
        case .askAssistant: return "/completion"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .askAssistant: return .post
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .askAssistant(_, let apiKey, _):
            return [
                "Authorization": "Bearer \(apiKey ?? "")",
                "Content-Type": "application/json"
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .askAssistant(let modelUri, _, let text):
            let requestBody = GPTRequestModel.init(modelUri: modelUri,
                                                   completionOptions: .init(maxTokens: 500, temperature: 0.3),
                                                   messages: [
                                                    .init(role: "system", text: "0"),
                                                    .init(role: "user", text: text)
                                                   ])
            return try? JSONEncoder().encode(requestBody)
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
