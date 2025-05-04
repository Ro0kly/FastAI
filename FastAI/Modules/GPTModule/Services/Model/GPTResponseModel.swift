//
//  GPTResponseModel.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation

struct GPTResponseModel: Codable {
    let result: GPTResult
}

struct GPTResult: Codable {
    let alternatives: [GPTAlternative]
}

struct GPTAlternative: Codable {
    let message: GPTMessage
}

struct GPTMessage: Codable {
    let role: String
    let text: String
}
