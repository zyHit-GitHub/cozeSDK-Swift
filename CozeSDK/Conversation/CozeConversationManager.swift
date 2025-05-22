//
//  CozeConversationManager.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public class CozeConversationManager{
    private let client: CozeClient

    public init(client: CozeClient) {
       self.client = client
    }
    
    
    // 创建会话
    // https://www.coze.cn/open/docs/developer_guides/create_conversation
    public func createConversation(
        userId: String?,
        metaData: [String: String]? = nil,
        messages: [CozeMessagePayload]? = nil,
        completion: @escaping (Result<CozeCreateConversationResponse, Error>) -> Void
    ) {
        let url = URL(string: "https://api.coze.cn/v1/conversation/create")!
        var requestPayload = CozeCreateConversationRequest(bot_id: client.botId)
        requestPayload.user = userId
        requestPayload.meta_data = metaData
        requestPayload.messages = messages

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(client.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestPayload)

        client.session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let response = try JSONDecoder().decode(CozeCreateConversationResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // 查看会话消息
    // https://www.coze.cn/open/docs/developer_guides/retrieve_conversation
    public func retrieveConversation(
        conversationId: String,
        completion: @escaping (Result<CozeRetrieveConversationResponse, Error>) -> Void
    ) {
        var components = URLComponents(string: "https://api.coze.cn/v1/conversation/retrieve")!
        components.queryItems = [
            URLQueryItem(name: "conversation_id", value: conversationId)
        ]

        guard let url = components.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(client.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        client.session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let response = try JSONDecoder().decode(CozeRetrieveConversationResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // 清除上下文
    // https://www.coze.cn/open/docs/developer_guides/clear_conversation_context
    public func clearConversation(
        conversationId: String,
        completion: @escaping (Result<CozeClearConversationResponse, Error>) -> Void
    ) {
        let urlString = "https://api.coze.cn/v1/conversations/\(conversationId)/clear"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(client.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8) // 明确传空 JSON

        client.session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let response = try JSONDecoder().decode(CozeClearConversationResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    //查看会话列表
    // https://www.coze.cn/open/docs/developer_guides/list_conversations
    public func listConversations(
        pageNum: Int = 1,
        pageSize: Int = 20,
        completion: @escaping (Result<CozeConversationListResponse, Error>) -> Void
    ) {
       
        var components = URLComponents(string: "https://api.coze.cn/v1/conversations")!
        components.queryItems = [
            URLQueryItem(name: "bot_id", value: client.botId),
            URLQueryItem(name: "page_num", value: "\(pageNum)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]

        guard let url = components.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(client.token)", forHTTPHeaderField: "Authorization")

        client.session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let response = try JSONDecoder().decode(CozeConversationListResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
}
