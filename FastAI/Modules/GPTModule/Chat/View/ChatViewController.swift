//
//  ChatViewController.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import UIKit

final class ChatViewController: UIViewController {
    
    private let chatViewModel: ChatViewModel = .init()
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(MessageCell.self, forCellReuseIdentifier: MessageCell.id)
        t.separatorStyle = .none
        t.backgroundColor = .systemGray6
        t.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 36)
        textViewHeightConstraint.isActive = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInputTextView),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
        chatViewModel.onMessageUpdated = { [weak self] in
            self?.tableView.reloadData()
            if let messageCount = self?.chatViewModel.messages.count {
                print(messageCount)
                self?.tableView.scrollToRow(
                    at: .init(row: messageCount - 1, section: 0),
                    at: .bottom,
                    animated: true
                )
            }
        }
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
        view.backgroundColor = .white
        title = "AI Чат"
        view.addSubview(tableView)
        view.addSubview(inputTextView)
        view.addSubview(sendButton)
        tableView.delegate = self
        tableView.dataSource = self
        
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
    private func sendMessage() {
        startProcessRequest()
        inputTextView.text = "Привет! Назови мне 4 принципа ООП"
        guard let text = inputTextView.text, !text.isEmpty else { return }
        chatViewModel.sendMessage(text, requestFinished: { [weak self] in
            self?.endProcessRequest()
        })
    }
        
    private func startProcessRequest() {
        sendButton.showLoading()
        inputTextView.isUserInteractionEnabled = false
    }
    
    private func endProcessRequest() {
        inputTextView.isUserInteractionEnabled = true
        sendButton.hideLoading()
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.id, for: indexPath) as? MessageCell else {
            return .init()
        }
        cell.configure(with: chatViewModel.messages[indexPath.row])
        return cell
    }
}
