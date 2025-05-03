//
//  SendButton.swift
//  FastAI
//
//  Created by Rookly on 02.05.2025.
//

import Foundation
import UIKit

final class SendButton: UIButton {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    let image = UIImage(systemName: "arrow.forward.circle.fill")?
        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)).withTintColor(.blue)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        setImage(image, for: .normal)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        addSubview(activityIndicator)
    }
    
    func showLoading() {
        isEnabled = false
        setImage(nil, for: .normal)
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        setImage(image, for: .normal)
        isEnabled = true
    }
}
