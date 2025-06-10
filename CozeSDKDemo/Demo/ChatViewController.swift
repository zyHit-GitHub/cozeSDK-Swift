//
//  ChatViewController.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/6/3.
//

import UIKit
import Network


struct ChatMessage {
    var text: String
    let isUser: Bool
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    private var messages: [ChatMessage] = []
    let tableView = UITableView()
    let inputField = UITextField()
    let sendButton = UIButton(type: .system)
    var inputFieldBottomConstraint: NSLayoutConstraint!
    
    private let chatManager = CozeSDK.shared.chat
    var conversationId : String?
    
    // 是否继续识别
    var continueToVR = false
    private var lastRecognizedText: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coze Chat"
        view.backgroundColor = .white
        setupUI()
        
        // 添加点击手势收起键盘
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
       tapGesture.cancelsTouchesInView = false
       view.addGestureRecognizer(tapGesture)
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
   
    
    
    
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        inputField.placeholder = "请输入内容"
        inputField.borderStyle = .roundedRect
        sendButton.setTitle("发送", for: .normal)
        
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(inputField)
        view.addSubview(sendButton)
        
        inputFieldBottomConstraint = inputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputFieldBottomConstraint,
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 44),

            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: inputField.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc private func sendTapped() {
        view.endEditing(true)
        
        guard let text = inputField.text, !text.isEmpty else { return }
        self.messages.append(ChatMessage(text: text, isUser: true))
        self.messages.append(ChatMessage(text: "机器人正在搜索...", isUser: false))
        tableView.reloadData()
        inputField.text = ""
       
        
        
        let request = StreamingChatRequest(
            conversationId: conversationId, botId: APIConfig.botId,
            userId: "user_123",
            autoSaveHistory: true,
            additionalMessages: [
                CozeMessagePayload(role: .user, content: text, content_type: CozeContentType(rawValue: "text") ?? .text)
            ]
        )

        chatManager?.startStreamingChat(
            request: request,
            onEvent: { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .chatCreated(let event):
                    self.conversationId = event.conversation_id
                case .chatInProgress(_):
                    self.displayAgentSearching()
                case .messageDelta(let delta):
                    self.setContrlEnable(isEnabled: true)
                    guard delta.role == .assistant, delta.type == .answer else { return }
                    self.displayAgentLoading()
                    
                case .messageCompleted(let message):
                    self.setContrlEnable(isEnabled: true)
                    guard message.role == .assistant else { return }

                    DispatchQueue.main.async {
                        switch message.type {
                        case .question:
                            break
                        case .answer:
                            self.displayAnswar(message: message)
                        case .function_call:
                            self.displayAgentSearching()
                        case .tool_output,.tool_response:
                            self.displayAgentSearching()
                        case .follow_up:
                            break
                        case .verbose:
                            break
                        case .unknown:
                            break
                        }
                   
                    }
                case .chatCompleted(_):
                    self.setContrlEnable(isEnabled: true)
                case .done:
                    self.setContrlEnable(isEnabled: true)
                case .unknown(event: _, data: _):
                    break
                case .chatFailed(_):
                    break
                case .chatRequiresAction(_):
                    break
                case .audioDelta(_):
                    break
                case .error(code: let code, message: let message):
                    break
                }
            },
            onError: { error in
                print("连接失败: \(error)")
            }
        )
    }
    
    
    private func setContrlEnable(isEnabled:Bool) {
        DispatchQueue.main.async {
            self.inputField.isEnabled = isEnabled
            self.sendButton.isEnabled = isEnabled
        }
    }
    
    
    
    private func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        
        if message.isUser {
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.textColor = .black
        } else {
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .darkGray
        }
        
        return cell
    }
}


extension ChatViewController{
    
    
    private func displayAnswar(message:CozeMessageDelta) {
        
        let fullText = message.content
        var currentText = ""

        // 替换最后一条 loading 消息为空字符串，准备打字
        if self.messages.last?.isUser == false {
            self.messages[self.messages.count - 1].text = ""
        } else {
            self.messages.append(ChatMessage(text: "", isUser: false))
        }

        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            guard charIndex < fullText.count else {
                timer.invalidate()
                return
            }
            let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
            currentText.append(fullText[index])
            self.messages[self.messages.count - 1].text = currentText

            self.tableView.reloadRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .none)
            self.scrollToBottom()
            charIndex += 1
        }
        
    }
    
    
    private func displayAgentLoading() {
        DispatchQueue.main.async {
            if self.messages.last?.isUser == false {
                let text = "机器人正在输入..."
                self.messages[self.messages.count - 1].text = text
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
       
    }
    
    private func displayAgentSearching() {
        DispatchQueue.main.async {
            if self.messages.last?.isUser == false {
                let text = "机器人正在搜索..."
                self.messages[self.messages.count - 1].text = text
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
       
    }
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        inputFieldBottomConstraint.constant = -keyboardFrame.height - 8
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        inputFieldBottomConstraint.constant = -16
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


