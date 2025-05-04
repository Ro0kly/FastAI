//
//  ImageGenerationViewModel.swift
//  FastAI
//
//  Created by Rookly on 03.05.2025.
//

import Foundation

class ImageGenerationViewModel {
    
    enum ImageGenerationStatus { case emptyResponse, filledResponse, loading }
    
    var generationStatus: ImageGenerationStatus = .emptyResponse {
        willSet { onUpdateImages?(newValue) }
    }
    
    var readyImages: [String] = []
    var imagesToGenerateCount: Int = 1
    var onUpdateImages: ((ImageGenerationStatus) -> Void)?
    var onGoToChat: (() -> Void)?
    
    private let gptService: GPTService
    
    init(gptService: GPTService) {
        self.gptService = gptService
    }
    
    func getImages(count: Int, text: String) {
        readyImages.removeAll()
        generationStatus = .loading
        gptService.getImages(messages: Array(repeating: text, count: count)) { [weak self] imageStringCodes in
            if imageStringCodes.filter({!$0.isEmpty}).count == 0 {
                self?.generationStatus = .emptyResponse
            } else {
                self?.readyImages = imageStringCodes
                self?.generationStatus = .filledResponse
            }
        }
    }
    
    func showChat() {
        onGoToChat?()
    }
}
