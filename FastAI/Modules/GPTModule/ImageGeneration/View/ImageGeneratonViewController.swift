//
//  ImageGeneratonViewController.swift
//  FastAI
//
//  Created by Rookly on 03.05.2025.
//

import UIKit

class ImageGenerationCollectionFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let padding: CGFloat = 16
        let itemWidth = collectionView.bounds.width*0.4
        itemSize = .init(width: itemWidth, height: itemWidth*1.3)
        scrollDirection = .vertical
        minimumLineSpacing = padding
        minimumInteritemSpacing = padding
        sectionInset = .init(top: padding, left: padding*1.5, bottom: padding, right: padding * 1.5)
    }
}

class ImageGeneratonViewController: UIViewController {
    
    let viewModel: ImageGenerationViewModel
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private var collectionView: UICollectionView = {
        let layout = ImageGenerationCollectionFlowLayout()
        let c = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        c.register(ImageGenerationCollectionCell.self, forCellWithReuseIdentifier: ImageGenerationCollectionCell.id)
        c.backgroundColor = .systemGray6
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    private let inputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray6.cgColor
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let countButton: UIButton = {
        let b = UIButton.init(type: .system)
        b.layer.cornerRadius = 12
        b.backgroundColor = UIColor.systemGray5
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("1", for: .normal)
        b.showsMenuAsPrimaryAction = true
        return b
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel.init()
        l.text = "Напишите ваше пожелание,\nвыберите количество картинок\nи вперед!"
        l.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    private let sendButton: SendButton = {
        let b = SendButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
        
    init(viewModel: ImageGenerationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInputTextView),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
        
        viewModel.onUpdateImages = { [weak self] generationStatus in
            DispatchQueue.main.async {
                switch generationStatus {
                case .emptyResponse:
                    self?.sendButton.hideLoading()
                    self?.navigationItem.rightBarButtonItem?.isHidden = false
                    self?.inputTextView.isUserInteractionEnabled = true
                    self?.descriptionLabel.text = "Попробуйте еще раз"
                    self?.descriptionLabel.isHidden = false
                case .filledResponse:
                    self?.sendButton.hideLoading()
                    self?.navigationItem.rightBarButtonItem?.isHidden = false
                    self?.inputTextView.isUserInteractionEnabled = true
                    self?.descriptionLabel.text = ""
                    self?.descriptionLabel.isHidden = true
                case .loading:
                    self?.sendButton.showLoading()
                    self?.navigationItem.rightBarButtonItem?.isHidden = true
                    self?.inputTextView.isUserInteractionEnabled = false
                    self?.descriptionLabel.text = "Начинаю генерировать!"
                    self?.descriptionLabel.isHidden = false
                }
                self?.collectionView.reloadData()
            }
        }
        
        setupUI()
    }
    
    @objc private func handleInputTextView() {
        let inputTextViewWidth = inputTextView.frame.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: inputTextViewWidth, height: .greatestFiniteMagnitude))
        
        let maxHeight: CGFloat = 120
        let newHeight = min(newSize.height, maxHeight)
        
        textViewHeightConstraint.constant = newHeight
        inputTextView.isScrollEnabled = newHeight >= maxHeight
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = .init(
            image: UIImage(systemName: "text.bubble"),
            style: .plain,
            target: self,
            action: #selector(showChat)
        )
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .white
        title = "AI-Картинка"
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 36)
        textViewHeightConstraint.isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        view.addSubview(inputTextView)
        view.addSubview(countButton)
        view.addSubview(sendButton)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            inputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: countButton.leadingAnchor, constant: -16),
            
            countButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            countButton.widthAnchor.constraint(equalToConstant: 40),
            countButton.heightAnchor.constraint(equalToConstant: 40),
            countButton.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        sendButton.addTarget(self, action: #selector(getImages), for: .touchUpInside)
        
        countButton.menu = configureCountButtonMenu()
    }
    
    @objc
    func showChat() {
        viewModel.onGoToChat?()
    }
    
    func configureCountButtonMenu() -> UIMenu {
        let actions = [1,2,3,4,5,6].map { [weak self] count in
            UIAction(title: "\(count) штук",
                     state: .on) { [weak self] _ in
                self?.countButton.setTitle("\(count)", for: .normal)
                self?.viewModel.imagesToGenerateCount = count
            }
        }
        
        return UIMenu(title: "Выберите количество",
                     options: .singleSelection,
                     children: actions)
    }
    
    @objc
    func getImages() {
        guard let text = inputTextView.text, !text.isEmpty else { return }
        viewModel.getImages(count: viewModel.imagesToGenerateCount, text: text)
        inputTextView.text = ""
    }
}

extension ImageGeneratonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.readyImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageGenerationCollectionCell.id, for: indexPath) as? ImageGenerationCollectionCell else {
            return .init()
        }
        if viewModel.readyImages.filter({!$0.isEmpty}).count != 0 {
            cell.configure(with: viewModel.readyImages[indexPath.row])
        }
        return cell
    }
}
