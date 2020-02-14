//
//  QuestionModel.swift
//  Wifiesta
//
//  Created by Badal1 Yadav on 10/02/20.
//  Copyright © 2020 Badal1 Yadav. All rights reserved.
//

import Foundation

// MARK: -
// MARK: - QuestionModel
struct QuestionModel: Codable { // User response model
    let Questions: [QuestionPayload]?
}
struct QuestionPayload: Codable {
    let Id, question: String?
}
