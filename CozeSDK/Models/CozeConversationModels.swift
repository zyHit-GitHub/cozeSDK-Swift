//
//  CozeModels.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public enum CozeRole: String, Codable {
    case user // 用户
    case assistant//机器人
}

public struct CozeCreateConversationRequest: Codable {
    public var bot_id: String
    public var user: String?
    public var meta_data: [String: String]?
    public var messages: [CozeMessagePayload]?
}

public struct CozeMessagePayload: Codable {
    public let role: CozeRole
    public let content: String
    public let content_type: String
}


public struct ConversationData: Codable {
    ///Conversation ID，即会话的唯一标识。
    public let id: String
    ///会话创建的时间。格式为 10 位的 Unixtime 时间戳，单位为秒。
    public let created_at: Int
    public let last_section_id: String?
    ///创建消息时的附加消息，获取消息时也会返回此附加消息。
    public let meta_data: [String: String]?
}

public struct ConversationSectionData: Codable {
    public let id: String
    public let conversation_id: String
}

public struct Detail: Codable {
    public let logid: String?//请求的日志 ID
}



// 创建会话Response
public struct CozeCreateConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: ConversationData
    public let detail: Detail?
}

// 会话item
public struct CozeRetrieveConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: ConversationData
}


// 清除会话Response
public struct CozeClearConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: ConversationSectionData
    public let detail: Detail?
}

public struct CozeConversationListResponse: Codable {
   
    public struct ListConversationData: Codable {
        //是否还有更多会话未在本次请求中返回。
        //true：还有更多未返回的会话。
        //false：已返回符合筛选条件的全部会话。
        public let has_more: Bool
        public let conversations: [ConversationData]
    }

    public let code: Int
    public let msg: String
    public let data: ListConversationData
    public let detail: Detail?
}
