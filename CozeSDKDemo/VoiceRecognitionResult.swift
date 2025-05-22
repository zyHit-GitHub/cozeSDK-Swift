//
//  VoiceRecognitionResult.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/30.
//

import Foundation

struct VoiceRecognitionResultModel: Decodable {
    let resultsRecognition: [String]
    let originResult: OriginResult

    enum CodingKeys: String, CodingKey {
        case resultsRecognition = "results_recognition"
        case originResult = "origin_result"
    }

    var recognizedText: String {
        resultsRecognition.first ?? ""
    }

    var confidence: Int? {
        originResult.result.confident.first
    }

    var words: [String] {
        originResult.result.word
    }
}

struct OriginResult: Decodable {
    let errNo: Int
    let result: RecognitionDetail
    let productId: Int
    let corpusNo: Int64
    let sn: String
    let resultType: String
    let productLine: String

    enum CodingKeys: String, CodingKey {
        case errNo = "err_no"
        case result
        case productId = "product_id"
        case corpusNo = "corpus_no"
        case sn
        case resultType = "result_type"
        case productLine = "product_line"
    }
}

struct RecognitionDetail: Decodable {
    let confident: [Int]
    let word: [String]
}

extension VoiceRecognitionResultModel {
    static func from(_ dictionary: [String: Any]) -> VoiceRecognitionResultModel? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let model = try? JSONDecoder().decode(VoiceRecognitionResultModel.self, from: data) else {
            return nil
        }
        return model
    }
}
