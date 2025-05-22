//
//  CozeClient.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public class CozeClient: NSObject {
    public let token: String
    public let botId: String
    public let session: URLSession
    
    public init(token: String, botId: String, session: URLSession = .shared) {
        self.token = token
        self.botId = botId
        self.session = session
    }
    
    
    public func makeRequest(
        to url: URL,
        method: String = "POST",
        body: [String: Any]? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

}
