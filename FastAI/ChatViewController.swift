//
//  ChatViewController.swift
//  FastAI
//
//  Created by Rookly on 01.05.2025.
//

import UIKit

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
    
    private let sendButton: UIButton = {
        let b = UIButton.init(type: .system)
        let image = UIImage(systemName: "arrow.forward.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)).withTintColor(.blue)
        b.setImage(image, for: .normal)
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
        askGPT(text: text)
    }
    
    private func askGPT(text: String) {
        print("A", Thread.current)
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            print("B", Thread.current)
            do {
                print("C", Thread.current)
                let response = try await gptService.sendMessage(messageText: text)
                print("D", Thread.current)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("E", Thread.current)
                    processResponse(response)
                    print("F", Thread.current)
                }
                print("G", Thread.current)
            } catch {
                print("REQUEST Error:", error)
            }
            print("H", Thread.current)
        }
        print("K", Thread.current)
//        gptService.sendMessage(messageText: text) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let success):
//                    print("ASK GPT SUCCESS:", success)
//                    self?.processResponse(success)
//                case .failure(let failure):
//                    print("ASK GPT FAILURE:", failure)
//                }
//            }
//        }
    }
    
    private func processResponse(_ response: GPTResponseModel) {
        guard let text = inputTextView.text else { return }
        messages.append(.init(text: text, isUser: true))
        guard let firstAlternative = response.result.alternatives.first else { return }
        messages.append(.init(text: firstAlternative.message.text, isUser: false))
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let numberOfSections = self?.tableView.numberOfSections, let numberOfRows = self?.tableView.numberOfRows(inSection: numberOfSections - 1) else {
                return
            }
            let lastRow = numberOfRows - 1
            let lastSection = numberOfSections - 1
            if numberOfRows - 1 >= 0 {
                let indexPath = IndexPath(row: lastRow, section: lastSection)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
