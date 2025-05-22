//
//  CozeModels.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit


public struct CozeConversation: Codable {
    ///Conversation ID，即会话的唯一标识。
    public let id: String
    ///会话创建的时间。格式为 10 位的 Unixtime 时间戳，单位为秒。
    public let created_at: Int
    public let last_section_id: String?
    ///创建消息时的附加消息，获取消息时也会返回此附加消息。
    public let meta_data: [String: String]?
}

public struct CozeConversationSection: Codable {
    public let id: String
    public let conversation_id: String
}



//会话创建请求
public struct CozeCreateConversationRequest: Codable {
    public let bot_id: String
    public let user: String?
    public let meta_data: [String: String]?
    public let messages: [CozeMessagePayload]?
    
    public init(bot_id: String, user: String? = nil, meta_data: [String: String]? = nil, messages: [CozeMessagePayload]? = nil) {
            self.bot_id = bot_id
            self.user = user
            self.meta_data = meta_data
            self.messages = messages
        }
}

public struct CozeMessagePayload: Codable {
    public let role: CozeRole
    public let content: String
    public let content_type: CozeContentType
}




// 创建会话Response
public struct CozeCreateConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: CozeConversation
    public let detail: CozeDetail?
}

// 会话item
public struct CozeRetrieveConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: CozeConversation
}


// 清除会话Response
public struct CozeClearConversationResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: CozeConversationSection
    public let detail: CozeDetail?
}



//会话列表响应
public struct CozeConversationListResponse: Codable {
    public let code: Int
    public let msg: String
    public let data: CozeConversationListData
    public let detail: CozeDetail?
}


public struct CozeConversationListData: Codable {
    //是否还有更多会话未在本次请求中返回。
    //true：还有更多未返回的会话。
    //false：已返回符合筛选条件的全部会话。
    public let has_more: Bool
    public let conversations: [CozeConversation]
}
