//
//  GPTImageGenerationResponseModel.swift
//  FastAI
//
//  Created by Rookly on 04.05.2025.
//

struct GPTImageGenerationResponseModel: Codable {
    let id: String
    let done: Bool
    let response: Response?
    
    struct Response: Codable {
        let image: String
    }
}
