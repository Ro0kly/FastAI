//
//  ChatViewController.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import UIKit

class SendButton: UIButton {
    
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

final class ChatViewController: UIViewController {
    
    private let gptService: GPTService = .init()
    private var messages: [MessageBlobModel] = []
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
            selector: #selector(adjustTextViewHeight),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func adjustTextViewHeight() {
        let fixedWidth = inputTextView.frame.width
        let newSize = inputTextView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        
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
        inputTextView.text = "Привет! Назови мне 4 принципа ООП"
        guard let text = inputTextView.text, !text.isEmpty else { return }
        messages.append(.init(text: text, isUser: true))
        tableView.insertRows(at: [.init(row: messages.count-1, section: 0)], with: .automatic)
        tableView.reloadRows(at: [.init(row: messages.count-1, section: 0)], with: .none)
        tableView.scrollToRow(at: .init(row: messages.count-1, section: 0), at: .bottom, animated: true)
        askGPT(text: text)
    }
    
    private func askGPT(text: String) {
        sendButton.showLoading()
        Task {
            do {
                let response = try await gptService.sendMessage(messageText: text)
                await processResponse(response)
            } catch {
                print("REQUEST Error:", error)
            }
        }
    }
    
    private func processResponse(_ response: GPTResponseModel) async {
        guard let firstAlternative = response.result.alternatives.first else { return }
        let parts = firstAlternative.message.text.components(separatedBy: "\n")
        Task {
            for (i,p) in parts.enumerated() {
                if i == 0 {
                    messages.append(.init(text: p, isUser: false))
                    tableView.insertRows(at: [.init(row: messages.count-1, section: 0)], with: .automatic)
                    tableView.reloadRows(at: [.init(row: messages.count-1, section: 0)], with: .none)
                    tableView.scrollToRow(at: .init(row: messages.count-1, section: 0), at: .bottom, animated: true)
                } else {
                    messages[messages.count-1].text.append("\n" + p)
                    tableView.reloadRows(at: [.init(row: messages.count-1, section: 0)], with: .none)
                    tableView.scrollToRow(at: .init(row: messages.count-1, section: 0), at: .bottom, animated: true)
                }
                try await Task.sleep(nanoseconds: 500_000_000)
                if i == parts.count - 1 {
                    print("done")
                    await MainActor.run {
                        sendButton.hideLoading()
                    }
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.id, for: indexPath) as? MessageCell else {
            return .init()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}
