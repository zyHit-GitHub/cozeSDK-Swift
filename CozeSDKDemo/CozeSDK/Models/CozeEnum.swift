//
//  CozeEnum.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/5/6.
//

import UIKit

struct EmptyPayload: Codable {}

public enum CozeRole: String, Codable {
    case user = "user" // 用户
    case assistant = "assistant"//机器人
}

public enum CozeContentType: String, Codable {
    case text = "text"
    case objectString = "object_string"
}


public enum CozeOrderType: String, Codable {
    case asc = "asc"
    case desc = "desc"
}


public enum StreamingEvent {
    case chatCreated(CozeChatEvent)
    case chatInProgress(CozeChatEvent)
    case chatCompleted(CozeChatEvent)
    case chatFailed(CozeChatEvent)
    case chatRequiresAction(CozeChatEvent)

    case messageDelta(CozeMessageDelta)
    case messageCompleted(CozeMessageDelta)
    case audioDelta(CozeMessageDelta)

    case error(code: Int?, message: String?)
    case done

    case unknown(event: String, data: String)
}


public enum CozeMessageType: String, Decodable {
    case question         // 用户输入
    case answer           // 智能体返回消息
    case function_call    // 智能体发起函数调用
    case tool_output      // 工具函数返回结果
    case tool_response    // 同上（别名）
    case follow_up        // 推荐问题内容
    case verbose          // 结束标志包
    case unknown          // 其他未识别类型

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = CozeMessageType(rawValue: raw) ?? .unknown
    }
}
