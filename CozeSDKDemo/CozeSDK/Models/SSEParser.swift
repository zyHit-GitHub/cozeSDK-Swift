//
//  SSEParser.swift
//  CozeSDKDemo
//
//  Created by subs on 2025/5/6.
//


import Foundation

public class SSEParser {
    private var buffer = ""
    private var currentEvent = ""
    private var currentDataLines: [String] = []

    /// 事件回调：传出 event 类型和原始 data 字符串
    public var onRawEvent: ((_ event: String, _ data: String) -> Void)?

    /// 你也可以直接传入解析为 StreamingEvent 的回调
    public var onParsedEvent: ((_ event: StreamingEvent) -> Void)?

    public init() {}

    public func append(_ data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }

        buffer.append(string)
        let lines = buffer.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix("event:") {
                currentEvent = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
                print("currentEvent:\(currentEvent)")
            } else if line.hasPrefix("data:") {
                let dataLine = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
                currentDataLines.append(dataLine)
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                let fullData = currentDataLines.joined(separator: "\n")
                if !fullData.isEmpty {
                    onRawEvent?(currentEvent, fullData)
                    parseAndEmit(event: currentEvent, data: fullData)
                }
                currentEvent = ""
                currentDataLines.removeAll()
            }
           
        }

        if buffer.contains("[DONE]") {
            onRawEvent?("done", "[DONE]")
            onParsedEvent?(.done)
            buffer = ""
        }
    }

    public func reset() {
        buffer = ""
        currentEvent = ""
        currentDataLines.removeAll()
    }

    /// 将原始事件映射为你的 StreamingEvent
    private func parseAndEmit(event: String, data: String) {
        guard let jsonData = data.data(using: .utf8) else {
            onParsedEvent?(.unknown(event: event, data: data))
            return
        }

        switch event {
        case "conversation.chat.created":
            if let obj = try? JSONDecoder().decode(CozeChatEvent.self, from: jsonData) {
                onParsedEvent?(.chatCreated(obj))
            }

        case "conversation.chat.in_progress":
            if let obj = try? JSONDecoder().decode(CozeChatEvent.self, from: jsonData) {
                onParsedEvent?(.chatInProgress(obj))
            }

        case "conversation.chat.completed":
            if let obj = try? JSONDecoder().decode(CozeChatEvent.self, from: jsonData) {
                onParsedEvent?(.chatCompleted(obj))
            }

        case "conversation.chat.failed":
            if let obj = try? JSONDecoder().decode(CozeChatEvent.self, from: jsonData) {
                onParsedEvent?(.chatFailed(obj))
            }

        case "conversation.chat.requires_action":
            if let obj = try? JSONDecoder().decode(CozeChatEvent.self, from: jsonData) {
                onParsedEvent?(.chatRequiresAction(obj))
            }

        case "conversation.message.delta":
            if let obj = try? JSONDecoder().decode(CozeMessageDelta.self, from: jsonData) {
                onParsedEvent?(.messageDelta(obj))
            }

        case "conversation.message.completed":
            if let obj = try? JSONDecoder().decode(CozeMessageDelta.self, from: jsonData) {
                onParsedEvent?(.messageCompleted(obj))
            }

        case "conversation.audio.delta":
            if let obj = try? JSONDecoder().decode(CozeMessageDelta.self, from: jsonData) {
                onParsedEvent?(.audioDelta(obj))
            }

        case "error":
            if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let code = json["code"] as? Int
                let msg = json["msg"] as? String
                onParsedEvent?(.error(code: code, message: msg))
            } else {
                onParsedEvent?(.error(code: nil, message: data))
            }

        case "done":
            onParsedEvent?(.done)

        default:
            onParsedEvent?(.unknown(event: event, data: data))
        }
    }
}

// MARK: - 示例用法

public class SSEClient {
    private var task: URLSessionDataTask?
    private let parser = SSEParser()
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func startStreaming(
        url: URL,
        headers: [String: String],
        body: Data,
        onEvent: @escaping (StreamingEvent) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = 60 * 5  // 长连接，设置更长超时时间
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        parser.onParsedEvent = { event in
            onEvent(event)
        }

        task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
               onError(error)
               return
            }

            guard let data = data else {
                onEvent(.unknown(event: "error", data: "Empty response"))
                return
            }

            self?.parser.append(data)
        }

        task?.resume()
    }

    public func disconnect() {
        task?.cancel()
        parser.reset()
    }
}
