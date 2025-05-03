//
//  NetworkService.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation

typealias NetworkCompletion<T> = (Result<T, NetworkError>) -> Void

final class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type, completion: @escaping NetworkCompletion<T>) {
        guard let urlRequest = endpoint.urlRequest else {
            completion(.failure(.badURL))
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.badData))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(.badResponse(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.badDecoding))
            }
        }.resume()
    }
}
