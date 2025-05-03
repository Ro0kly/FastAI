//
//  AuthViewModel.swift
//  FastAI
//
//  Created by Rookly on 03.05.2025.
//

import SwiftUI

final class AuthViewModel: ObservableObject {
    
    private var userDataService: UserDataService
    
    @Published var apiKey: String = ""
    @Published var modelUri: String = ""
    
    var onLogingSuccess: (() -> Void)?
    
    init(userDataService: UserDataService) {
        self.userDataService = userDataService
    }
    
    func login() {
        do {
            try userDataService.login(apiKey: apiKey, modelUri: modelUri)
            onLogingSuccess?()
        } catch let error {
            print("login error:", error)
        }
    }
}
