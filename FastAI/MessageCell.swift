//
//  MessageCell.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import Foundation
import UIKit

final class MessageCell: UITableViewCell {
    
    static let id: String = "MessageCell"
    
    private let messageLabel: UILabel = {
        let l = PaddingLabel()
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.clipsToBounds = true
        l.layer.cornerRadius = 12
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NSLayoutConstraint.deactivate(constraints)
    }
    
    func configure(with message: MessageBlobModel) {
        messageLabel.text = message.text
        messageLabel.textColor = message.isUser ? .white : .black
        messageLabel.backgroundColor = message.isUser ? .systemBlue : .systemGray5
        if message.isUser {
            messageLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width*0.5).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        } else {
            messageLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width*0.8).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        }
    }
}
