//
//  CozeChatModel.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/5/6.
//

import UIKit


public struct StreamingChatRequest {
    public var conversationId: String?
    public var botId: String
    public var userId: String
    public var autoSaveHistory: Bool = true
    public var additionalMessages: [CozeMessagePayload]
    public let parameters: [String: AnyEncodable]?
    public let custom_variables: [String: String]?



   public init(conversationId: String? = nil,
               botId: String,
               userId: String,
               autoSaveHistory: Bool = true,
               additionalMessages: [CozeMessagePayload],
               parameters:[String: AnyEncodable]? = nil,
               customVariables: [String: String]? = nil) {
       self.conversationId = conversationId
       self.botId = botId
       self.userId = userId
       self.autoSaveHistory = autoSaveHistory
       self.additionalMessages = additionalMessages
       self.parameters = parameters
       self.custom_variables = customVariables
   }
}

public struct StreamingChatRequestBody: Encodable {
    let bot_id: String
    let user_id: String
    let stream: Bool
    let auto_save_history: Bool
    let additional_messages: [CozeMessagePayload]
    let parameters: [String: AnyEncodable]?
    let custom_variables: [String: String]?



    public init(from req: StreamingChatRequest, stream: Bool = true) {
        self.bot_id = req.botId
        self.user_id = req.userId
        self.stream = stream
        self.auto_save_history = req.autoSaveHistory
        self.parameters = req.parameters
        self.custom_variables = req.custom_variables
        self.additional_messages = req.additionalMessages.map {
            CozeMessagePayload(
                role: CozeRole(rawValue: $0.role.rawValue) ?? .user,
                content: $0.content,
                content_type: $0.content_type
            )
        }
    }
   
    // 打印
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("Failed to convert to dictionary: \(error)")
            return nil
        }
    }

   
}



public struct CozeChatEvent: Codable {
    public let id: String
    public let conversation_id: String
    public let bot_id: String
    public let created_at: Int?
    public let completed_at: Int?
    public let last_error: CozeChatError
    public let status: String
    public let usage: CozeChatUsage
}

public struct CozeChatError: Codable {
    public let code: Int
    public let msg: String
}

public struct CozeChatUsage: Codable {
    public let token_count: Int
    public let output_count: Int
    public let input_count: Int
}

public struct CozeMessageDelta: Decodable {
    public let id: String
    public let conversation_id: String
    public let bot_id: String
    public let role: CozeRole
    public let type: CozeMessageType
    public let content: String
    public let content_type: CozeContentType
    public let chat_id: String
}


public struct ChatResponse: Decodable {
    public struct ChatData: Decodable {
        public let id: String
        public let conversation_id: String
        public let bot_id: String
        public let created_at: Int
        public let completed_at: Int
        public let last_error: CozeChatError?
        public let meta_data: [String: String]?
        public let status: String
        public let usage: CozeChatUsage
    }

    public let code: Int
    public let msg: String
    public let data: ChatData
}



// 对话详情Response
public struct CozeChatRetrieveResponse: Decodable {
    public let code: Int
    public let data: CozeChatInfo
    public let msg: String
}

public struct CozeChatInfo: Decodable {
    public let bot_id: String
    public let completed_at: Int
    public let conversation_id: String
    public let created_at: Int
    public let id: String
    public let status: String // status=completed 表示对话结束 可以查询对话详情
    public let usage: CozeChatUsage
}



public struct CozeChatMessageListResponse: Decodable {
    public let code: Int
    public let data: [CozeChatMessage]
    public let msg: String
    public let detail: CozeDetail?
}

public struct CozeChatMessage: Decodable {
    public let id: String
    public let bot_id: String
    public let content: String
    public let content_type: CozeContentType
    public let conversation_id: String
    public let role: CozeRole
    public let type: CozeMessageType
}


