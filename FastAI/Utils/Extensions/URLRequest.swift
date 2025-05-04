//
//  URLRequest.swift
//  FastAI
//
//  Created by Rookly on 04.05.2025.
//

import Foundation

extension URLRequest {
    var cURL: String {
        guard let url = url, let method = httpMethod else { return "" }
        
        var components = ["curl -v -X \(method)"]
        
        allHTTPHeaderFields?.forEach { key, value in
            components.append("-H \"\(key): \(value)\"")
        }
        
        if let httpBody = httpBody, !httpBody.isEmpty {
            let bodyString = String(data: httpBody, encoding: .utf8) ?? ""
            components.append("-d '\(bodyString)'")
        }
        
        components.append("\"\(url.absoluteString)\"")
        
        return components.joined(separator: " \\\n\t")
    }
}
