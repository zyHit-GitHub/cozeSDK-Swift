//
//  CozeSDK.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public class CozeSDK{
    public static let shared = CozeSDK()

    private(set) var client: CozeClient?

    private init() {}

    public func initialize(token: String, botId: String) {
        self.client = CozeClient(token: token, botId: botId)
    }

    public var conversation: CozeConversationManager? {
        guard let client = client else { return nil }
        return CozeConversationManager(client: client)
    }

    public var message: CozeMessageManager? {
        guard let client = client else { return nil }
        return CozeMessageManager(client: client)
    }

    public var chat: CozeChatManager? {
        guard let client = client else { return nil }
        return CozeChatManager(client: client)
    }
}
