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

}
