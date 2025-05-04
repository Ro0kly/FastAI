//
//  AuthService.swift
//  FastAI
//
//  Created by Rookly on 03.05.2025.
//

enum AuthConstants: CustomStringConvertible {
    case modelUri
    case apiKey
    var description: String {
        switch self {
        case .modelUri:
            return "modelUri"
        case .apiKey:
            return "apiKey"
        }
    }
}

enum AuthError: CustomStringConvertible, Error {
    case badApiKey
    case badModelUri
    
    var description: String {
        switch self {
        case .badApiKey:
            return "badApiKey"
        case .badModelUri:
            return "badModelUri"
        }
    }
}

final class UserDataService {
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    func login(apiKey: String, modelUri: String) throws {
        let isApiKeyUriSaved = keychainService.save(apiKey, forKey: AuthConstants.apiKey.description)
        let isModelUriSaved = keychainService.save(modelUri, forKey: AuthConstants.modelUri.description)
        
        if !isApiKeyUriSaved  {
            _ = keychainService.delete(forKey: AuthConstants.apiKey.description)
            _ = keychainService.delete(forKey: AuthConstants.modelUri.description)
            throw AuthError.badApiKey
        } else if !isModelUriSaved {
            _ = keychainService.delete(forKey: AuthConstants.apiKey.description)
            _ = keychainService.delete(forKey: AuthConstants.modelUri.description)
            throw AuthError.badModelUri
        }
    }
    
    func getApiKey() -> String? {
        return keychainService.get(forKey: AuthConstants.apiKey.description)
    }
    func getModelUri() -> String? {
        return keychainService.get(forKey: AuthConstants.modelUri.description)
    }
    func clearUserData() {
        _ = KeychainService.shared.delete(forKey: AuthConstants.modelUri.description)
        _ = KeychainService.shared.delete(forKey: AuthConstants.apiKey.description)
    }
}
