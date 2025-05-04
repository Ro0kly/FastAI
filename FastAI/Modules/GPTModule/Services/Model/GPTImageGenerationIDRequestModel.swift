//
//  GPTImageGenerationIDRequestModel.swift
//  FastAI
//
//  Created by Rookly on 04.05.2025.
//

struct GPTImageGenerationIDRequestModel: Codable {
    let modelUri: String?
    let messages: [MessageModel]
    let generationOptions: GenarationOptions
    
    struct MessageModel: Codable {
        let text: String
        let weigth: Int
    }
    
    struct GenarationOptions: Codable {
        let mimeType: String
        let seed: String
        let ratio: AspectRation
    }
    
    struct AspectRation: Codable {
        let widthRatio: Int
        let heightRation: Int
    }
}
