//
//  ImageGenerationCollectionCell.swift
//  FastAI
//
//  Created by Rookly on 04.05.2025.
//

import UIKit

class ImageGenerationCollectionCell: UICollectionViewCell {
    static let id = "ImageGenerationCollectionCell"
    private let imageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 16
        return img
    }()
    
    private let generationStatusLabel: UILabel = {
        let l = UILabel.init()
        l.text = "Ошибка\nгенерации"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: String) {
        if let data = image.toDataBase64(), let img = UIImage(data: data) {
            imageView.image = img
            generationStatusLabel.isHidden = true
        } else {
            imageView.image = nil
            imageView.backgroundColor = .systemGray2
            generationStatusLabel.isHidden = false
        }
    }
    
    private func setupUI() {
        imageView.frame = contentView.bounds
        generationStatusLabel.sizeToFit()
        generationStatusLabel.center = contentView.center
        contentView.addSubview(imageView)
        contentView.addSubview(generationStatusLabel)
    }
}
