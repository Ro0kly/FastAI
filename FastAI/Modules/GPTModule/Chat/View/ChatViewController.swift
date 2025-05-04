//
//  ChatViewController.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import UIKit

final class ChatViewController: UIViewController {
    
    let viewModel: ChatViewModel
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(MessageCell.self, forCellReuseIdentifier: MessageCell.id)
        t.separatorStyle = .none
        t.backgroundColor = .systemGray6
        t.translatesAutoresizingMaskIntoConstraints = false
        t.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
        return t
    }()
    
    private let inputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let sendButton: SendButton = {
        let b = SendButton.init()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        viewModel.showWelcomeMessage()
        
        viewModel.onMessageUpdated = { [weak self] in
            self?.tableView.reloadData()
            if let messageCount = self?.viewModel.messages.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.tableView.scrollToRow(
                        at: .init(row: messageCount - 1, section: 0),
                        at: .bottom,
                        animated: true
                    )
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInputTextView),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
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

    func setupUI() {
        navigationItem.rightBarButtonItem = .init(
            image: UIImage(systemName: "photo"),
            style: .plain,
            target: self,
            action: #selector(showImageGeneration)
        )
        navigationItem.leftBarButtonItem = .init(
            title: "Выход",
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        
        view.backgroundColor = .white
        title = "AI Чат"
        view.addSubview(tableView)
        view.addSubview(inputTextView)
        view.addSubview(sendButton)
        tableView.delegate = self
        tableView.dataSource = self
        
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 36)
        textViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -8),
            
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -16),
            inputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc
    func showImageGeneration() {
        viewModel.onGoToImageGeneration?()
    }
    
    @objc
    func logout() {
        viewModel.onLogout?()
    }

    
    @objc
    private func sendMessage() {
        guard let text = inputTextView.text, !text.isEmpty else { return }
        inputTextView.text = ""
        startProcessRequest()
        viewModel.sendMessage(text, requestFinished: { [weak self] in
            self?.endProcessRequest()
        })
    }
        
    private func startProcessRequest() {
        sendButton.showLoading()
        inputTextView.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isHidden = true
        navigationItem.leftBarButtonItem?.isHidden = true
    }
    
    private func endProcessRequest() {
        inputTextView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem?.isHidden = false
        navigationItem.leftBarButtonItem?.isHidden = false
        sendButton.hideLoading()
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.id, for: indexPath) as? MessageCell else {
            return .init()
        }
        cell.configure(with: viewModel.messages[indexPath.row])
        return cell
    }
}
