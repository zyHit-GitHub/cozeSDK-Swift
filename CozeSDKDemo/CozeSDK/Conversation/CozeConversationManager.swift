//
//  CozeConversationManager.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//  会话

import UIKit

public class CozeConversationManager{
    private let client: CozeClient

    public init(client: CozeClient) {
       self.client = client
    }
    
    
    /// 创建会话
    // https://www.coze.cn/open/docs/developer_guides/create_conversation
    public func createConversation(
        userId: String?,
        metaData: [String: String]? = nil,
        messages: [CozeMessagePayload]? = nil,
        completion: @escaping (Result<CozeCreateConversationResponse, Error>) -> Void
    ) {
        
        let fullPath = "/v1/conversation/create"
        let requestPayload = CozeCreateConversationRequest(bot_id: client.botId,user: userId,meta_data: metaData,messages: messages)
        client.post(path: fullPath, body: requestPayload, completion: completion)
    }
    
    
    /// 查看会话消息
    // https://www.coze.cn/open/docs/developer_guides/retrieve_conversation
    public func retrieveConversation(
        conversationId: String,
        completion: @escaping (Result<CozeRetrieveConversationResponse, Error>) -> Void
    ) {
        let path = "/v1/conversation/retrieve"
        let queryItems = [
            URLQueryItem(name: "conversation_id", value: conversationId)
        ]

        client.get(
            path: path,
            queryItems: queryItems,
            completion: completion
        )
    }
    
    
    
    /// 清除上下文
    // https://www.coze.cn/open/docs/developer_guides/clear_conversation_context
    public func clearConversation(
        conversationId: String,
        completion: @escaping (Result<CozeClearConversationResponse, Error>) -> Void
    ) {
        let path = "https://api.coze.cn/v1/conversations/\(conversationId)/clear"
            
        client.post(
            path: path,
            body: EmptyPayload(), // 可以定义一个空的 struct EmptyPayload: Codable {}
            completion: completion
        )
    }
    
    
    ///查看会话列表
    // https://www.coze.cn/open/docs/developer_guides/list_conversations
    public func listConversations(
        pageNum: Int = 1,
        pageSize: Int = 20,
        completion: @escaping (Result<CozeConversationListResponse, Error>) -> Void
    ) {
       
        let path = "/v1/conversations"
        let queryItems = [
            URLQueryItem(name: "bot_id", value: client.botId),
            URLQueryItem(name: "page_num", value: "\(pageNum)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
        client.get(
            path: path,
            queryItems: queryItems,
            completion: completion
        )
    }
    
    
}
