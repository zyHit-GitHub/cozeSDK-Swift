//
//  CozeMessageManager.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//  消息
//  给已有的会话（conversation）添加一条新的消息。
//  一般用于维护会话上下文，但不会触发 bot 回复。

import UIKit

public class CozeMessageManager{
    private let client: CozeClient

    public init(client: CozeClient) {
       self.client = client
    }
    
    
//    let manager = CozeMessageManager(client: yourCozeClient)
//    manager.createTextMessage(conversationId: "737999610479815****", text: "早上好，今天星期几？") { result in
//        switch result {
//        case .success(let response):
//            print("消息发送成功：\(response.data.id)")
//        case .failure(let error):
//            print("失败：\(error.localizedDescription)")
//        }
//    }
    // 创建文字消息 https://www.coze.cn/open/docs/developer_guides/create_message
    public func createTextMessage(
        conversationId: String,
        text: String,
        completion: @escaping (Result<CozeCreateMessageResponse, Error>) -> Void
    ) {
        let fullPath = "/v1/conversation/message/create?conversation_id=\(conversationId)"
        let payload = CozeCreateMessageRequest(role: .user, content: text, content_type: .text)
        client.post(path: fullPath,body: payload,completion: completion)
    }
    
    
    // 消息列表 https://www.coze.cn/open/docs/developer_guides/list_message
    public func listMessages(
        conversationId: String,
        request: CozeMessageListRequest,
        completion: @escaping (Result<CozeMessageListResponse, Error>) -> Void
    ) {
        let path = "/v1/conversation/message/list?conversation_id=\(conversationId)"
        
        client.post(
            path: path,
            body: request,
            completion: completion
        )
    }
    
    
    // 消息详情 https://www.coze.cn/open/docs/developer_guides/retrieve_message
    public func retrieveMessageDetail(
        conversationId: String,
        messageId: String,
        completion: @escaping (Result<CozeRetrieveMessageResponse, Error>) -> Void
    ) {
        let path = "/v1/conversation/message/retrieve"
        let queryItems = [
            URLQueryItem(name: "conversation_id", value: conversationId),
            URLQueryItem(name: "message_id", value: messageId)
        ]

        client.get(
            path: path,
            queryItems: queryItems,
            completion: completion
        )
    }
    
    // 修改消息 https://www.coze.cn/open/docs/developer_guides/modify_message
    public func modifyMessage(
        conversationId: String,
        messageId: String,
        newContent: String,
        completion: @escaping (Result<CozeModifyMessageResponse, Error>) -> Void
    ) {
        let url = "/v1/conversation/message/modify"
        let queryItems = [
            URLQueryItem(name: "conversation_id", value: conversationId),
            URLQueryItem(name: "message_id", value: messageId)
        ]
        let body = CozeModifyMessageRequest(content: newContent, content_type: .text)

        client.post(path: url, queryItems: queryItems, body: body, completion: completion)
    }

    
    // 删除消息 https://www.coze.cn/open/docs/developer_guides/delete_message
    public func deleteMessage(
        conversationId: String,
        messageId: String,
        completion: @escaping (Result<CozeDeleteMessageResponse, Error>) -> Void
    ) {
        let url = "/v1/conversation/message/delete"
        let queryItems = [
            URLQueryItem(name: "conversation_id", value: conversationId),
            URLQueryItem(name: "message_id", value: messageId)
        ]

        client.post(path: url, queryItems: queryItems, body: EmptyPayload(), completion: completion)
    }
}
