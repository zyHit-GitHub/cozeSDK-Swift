//
//  CozeMessageModels.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/18.
//

import UIKit


public struct CozeMessage: Decodable {
    public let id: String
    public let bot_id: String?
    public let chat_id: String?
    public let conversation_id: String
    public let role: CozeRole
    public let content: String
    public let content_type: CozeContentType
    public let created_at: Int
    public let updated_at: Int
    public let meta_data: [String: String]?
    public let type: CozeMessageType?
}


//请求结构体
public struct CozeCreateMessageRequest: Codable {
    public let role: CozeRole
    public let content: String
    public let content_type: CozeContentType
}

public struct CozeModifyMessageRequest: Codable {
    public let content: String
    public let content_type: CozeContentType
}

public struct CozeMessageListRequest: Codable {
    public let limit: Int?
    public let order: CozeOrderType
    public let chat_id: String?
    public let before_id: String?
}



//响应结构体
public struct CozeCreateMessageResponse: Decodable {
    public let code: Int
    public let msg: String
    public let data: CozeMessage
}

public struct CozeModifyMessageResponse: Decodable {
    public let code: Int
    public let msg: String
    public let message: CozeMessage
}

public struct CozeDeleteMessageResponse: Decodable {
    public let code: Int
    public let msg: String
    public let data: CozeMessage
}

public struct CozeRetrieveMessageResponse: Decodable {
    public let code: Int
    public let msg: String
    public let data: CozeMessage
    public let detail: CozeDetail?
}

public struct CozeMessageListResponse: Decodable {
    public let code: Int
    public let msg: String
    public let data: [CozeMessage]
    public let first_id: String?
    public let last_id: String?
    public let has_more: Bool
}
