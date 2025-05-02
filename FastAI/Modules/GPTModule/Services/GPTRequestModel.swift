//
//  GPTRequestModel.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation

struct GPTRequestModel: Codable {
    let modelUri: String
    let completionOptions: CompletionOptions
    let messages: [Message]
    
    struct CompletionOptions: Codable {
        let maxTokens: Int
        let temperature: Double
    }
    
    struct Message: Codable {
        let role: String
        let text: String
    }
}
