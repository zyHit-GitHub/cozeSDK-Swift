//
//  CozeChatManager.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public class CozeChatManager {
    private let client: CozeClient
    private var sseClient: SSEClient?

    public init(client: CozeClient) {
        self.client = client
    }
    
//    示例使用:
//    let client = CozeClient(token: "your-token-here", botId: "bot_xxx")
//    let manager = CozeChatManager(client: client)
//
//    let request = StreamingChatRequest(
//        botId: "bot_xxx",
//        userId: "user_123",
//        autoSaveHistory: true,
//        additionalMessages: [
//            CozeMessagePayload(role: .user, content: "你好", content_type: "text")
//        ],
//        conversationId: nil  // 可选，继续某个对话则传 conversationId
//    )
//    
//    manager.startStreamingChat(
//        request: request,
//        onEvent: { event in
//            switch event {
//            case .chatCreated(let chat):
//                print("对话创建: \(chat)")
//            case .messageDelta(let delta):
//                print("收到流式片段: \(delta.message?.content ?? "")")
//            case .messageCompleted(let delta):
//                print("消息完成: \(delta)")
//            case .chatCompleted(let chat):
//                print("对话完成: \(chat)")
//            case .done:
//                print("对话流结束")
//            case .unknown(let event, let data):
//                print("未知事件: \(event), 数据: \(data)")
//            default:
//                break
//            }
//        },
//        onError: { error in
//            print("发生错误: \(error.localizedDescription)")
//        }
//    )
    
    
    

    /// 开始流式对话
    @discardableResult
    public func startStreamingChat(
        request: StreamingChatRequest,
        onEvent: @escaping (StreamingEvent) -> Void,
        onError: @escaping (Error) -> Void
    ) -> SSEClient? {
        var urlString = "https://api.coze.cn/v3/chat"
        if let cid = request.conversationId {
            urlString += "?conversation_id=\(cid)"
        }

        guard let url = URL(string: urlString) else {
            onError(NSError(domain: "CozeChatManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return nil
        }

        let headers = [
            "Authorization": "Bearer \(client.token)",
            "Content-Type": "application/json"
        ]

        let payload = StreamingChatRequestBody(from: request)

        let body: Data
        do {
            body = try JSONEncoder().encode(payload)
        } catch {
            onError(error)
            return nil
        }

        let sse = SSEClient()
        sse.startStreaming(
            url: url,
            headers: headers,
            body: body,
            onEvent: onEvent,
            onError: onError
        )
        self.sseClient = sse
        return sse
    }

    /// 停止当前流式对话
    public func stopStreamChat() {
        sseClient?.disconnect()
        sseClient = nil
    }
    
    
    /// 开始非流式对话
    public func startChat(
        request: StreamingChatRequest,
        completion: @escaping (Result<ChatResponse, Error>) -> Void
    ) {
        var queryItems: [URLQueryItem]? = nil
        if let cid = request.conversationId {
            queryItems = [URLQueryItem(name: "conversation_id", value: cid)]
        }

        let payload = StreamingChatRequestBody(from: request, stream: false)

        client.post(
            path: "/v3/chat",
            queryItems: queryItems,
            body: payload,
            completion: completion
        )
           
    }
    
    /// 查看对话详情
    /// 查看对话的详细信息。在非流式会话场景中，调用发起对话接口后，可以先轮询此 API 确认本轮对话已结束（status=completed）
    /// 再调用接口查看对话消息详情查看本轮对话的模型回复。
    public func getChatDetail(
        chatId: String,//即对话的唯一标识。
        conversationId: String,//会话的唯一标识。
        completion: @escaping (Result<CozeChatInfo, Error>) -> Void
    ) {
        let path = "https://api.coze.cn/v3/chat/retrieve"
        let queryItems = [
            URLQueryItem(name: "chat_id", value: chatId),
            URLQueryItem(name: "conversation_id", value: conversationId)
        ]

        client.get(path: path, queryItems: queryItems, completion: completion)
    }
    
    
    
    
}

