//
//  NetworkError.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case badURL
    case badData
    case badDecoding
    case badResponse(Int)
    case unknown(Error)
    case longResponse
    
    var description: String {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .badData:
            return "No Data"
        case .badDecoding:
            return "Decoding Error"
        case .badResponse(let value):
            return "Server Error: \(value)"
        case .unknown(let error):
            return "Unknow: \(error)"
        case .longResponse:
            return "Server is busy"
        }
    }
}
