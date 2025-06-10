//
//  ViewController.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/4/30.
//

import UIKit

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Coze demo"
        view.backgroundColor = .white
        setupButtons()
    }
    
    private func setupButtons() {
        let chatButton = createButton(title: "Chat", action: #selector(chatTapped))
        let conversationButton = createButton(title: "Conversation", action: #selector(conversationTapped))
        let messageButton = createButton(title: "Message", action: #selector(messageTapped))
        
        let stackView = UIStackView(arrangedSubviews: [chatButton, conversationButton, messageButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
           let button = UIButton(type: .system)
           button.setTitle(title, for: .normal)
           button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
           button.addTarget(self, action: action, for: .touchUpInside)
           return button
       }
       
       @objc private func chatTapped() {
           print("Chat button tapped")
            navigationController?.pushViewController(ChatViewController(), animated: true)
       }
       
       @objc private func conversationTapped() {
           print("Conversation button tapped")
            navigationController?.pushViewController(ConversationViewController(), animated: true)
       }
       
       @objc private func messageTapped() {
           print("Message button tapped")
            navigationController?.pushViewController(MessageViewController(), animated: true)
       }

}


