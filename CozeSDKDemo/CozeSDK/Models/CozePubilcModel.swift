//
//  CozePubilcModel.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/5/6.
//

import UIKit


public struct CozeDetail: Codable {
    public let logid: String
}

public struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        self.encodeFunc = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
